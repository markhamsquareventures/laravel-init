#!/usr/bin/env bash
# Proves that each laravel-init gate family engages. For each family, the script
# writes one violation, runs the check, and looks for the expected output. Then it
# removes the violation. Run it from the repo root after `composer gate` is green.
#
# Usage: negative-controls.sh
#        SKIP="shadcn knip" negative-controls.sh   (skip families that are off by decision)
#
# Exit 0 only when every family that is not skipped prints its expected output.

set -u

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
plain="$here/plain"
skip=" ${SKIP:-} "
backup_dir="$(mktemp -d)"
failures=0

probe_files=(
    app/Http/Controllers/ProbeController.php
    app/Models/ProbeModel.php
    app/Actions/ProbeAction.php
    app/Support/ProbeUntyped.php
    resources/js/pages/probe.tsx
)
restored_files=(
    resources/js/lib/utils.ts
    tests/Browser/SmokeTest.php
)

cleanup() {
    for file in "${probe_files[@]}"; do
        rm -f "$file"
    done
    for file in "${restored_files[@]}"; do
        if [[ -f "$backup_dir/$(basename "$file")" ]]; then
            cp "$backup_dir/$(basename "$file")" "$file"
        fi
    done
    rm -rf "$backup_dir"
}
trap cleanup EXIT

for file in "${probe_files[@]}"; do
    if [[ -e "$file" ]]; then
        echo "STOP: $file exists. The script uses this path for a probe."
        exit 2
    fi
done
for file in "${restored_files[@]}"; do
    if [[ ! -f "$file" ]]; then
        echo "STOP: $file is missing. The script needs it for a probe."
        exit 2
    fi
    cp "$file" "$backup_dir/$(basename "$file")"
done

# check <family> <expected text> <command...>
check() {
    local family="$1" expected="$2"
    shift 2
    if [[ "$skip" == *" $family "* ]]; then
        echo "SKIP  $family"
        return
    fi
    local output line
    output="$("$plain" "$@")"
    line="$(grep -F -m 1 -- "$expected" <<<"$output")"
    if [[ -n "$line" ]]; then
        echo "PASS  $family: $line"
    else
        echo "FAIL  $family: no line with \"$expected\""
        failures=$((failures + 1))
    fi
}

phpstan=(vendor/bin/phpstan analyse --error-format=raw --memory-limit=2G --no-progress)

# 1. Write ban.
cat >app/Http/Controllers/ProbeController.php <<'PHP'
<?php

namespace App\Http\Controllers;

use App\Models\User;

class ProbeController extends Controller
{
    public function update(User $user): void
    {
        $user->update(['name' => 'probe']);
    }
}
PHP
check write-ban 'Calling Illuminate\Database\Eloquent\Model::update()' "${phpstan[@]}"
rm -f app/Http/Controllers/ProbeController.php

# 2. A model that overrides a write method, called from a controller.
cat >app/Models/ProbeModel.php <<'PHP'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ProbeModel extends Model
{
    public function save(array $options = []): bool
    {
        return parent::save($options);
    }
}
PHP
cat >app/Http/Controllers/ProbeController.php <<'PHP'
<?php

namespace App\Http\Controllers;

use App\Models\ProbeModel;

class ProbeController extends Controller
{
    public function update(ProbeModel $probeModel): void
    {
        $probeModel->save();
    }
}
PHP
check override-ban 'matches App\Models\*::save()' "${phpstan[@]}"
rm -f app/Http/Controllers/ProbeController.php app/Models/ProbeModel.php

# 3. Arch: an action with no handle().
cat >app/Actions/ProbeAction.php <<'PHP'
<?php

namespace App\Actions;

final readonly class ProbeAction
{
    public function run(): void {}
}
PHP
check arch 'to have method [handle]' vendor/bin/pest tests/Arch --compact
rm -f app/Actions/ProbeAction.php

# 4. Dead code: an unused public method on a model.
cat >app/Models/ProbeModel.php <<'PHP'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ProbeModel extends Model
{
    public function unusedProbe(): void {}
}
PHP
check dead-code 'Unused App\Models\ProbeModel::unusedProbe' "${phpstan[@]}"
rm -f app/Models/ProbeModel.php

# 5. Type coverage: an untyped parameter.
mkdir -p app/Support
cat >app/Support/ProbeUntyped.php <<'PHP'
<?php

namespace App\Support;

final class ProbeUntyped
{
    public static function probe($value): void {}
}
PHP
check type-coverage 'Type coverage below expected' vendor/bin/pest --type-coverage --compact --min=100
rm -f app/Support/ProbeUntyped.php

# 6. oxlint: an image with no alt text.
cat >resources/js/pages/probe.tsx <<'TSX'
export default function Probe() {
    return <img src="/probe.png" />;
}
TSX
check oxlint 'jsx-a11y(alt-text)' pnpm exec vp lint

# 7. shadcn: a raw color class.
cat >resources/js/pages/probe.tsx <<'TSX'
export default function Probe() {
    return <div className="bg-red-500">probe</div>;
}
TSX
check shadcn 'shadcn(no-raw-colors)' pnpm exec vp lint
rm -f resources/js/pages/probe.tsx

# 8. knip: an export that nothing imports.
printf '\nexport function probeUnused(): void {}\n' >>resources/js/lib/utils.ts
check knip 'probeUnused' pnpm knip
cp "$backup_dir/utils.ts" resources/js/lib/utils.ts

# 9. Browser: a wrong expected path in the smoke test. Needs built assets.
perl -0pi -e "s/assertPathIs\('[^']*'\)/assertPathIs('\/probe-wrong')/" tests/Browser/SmokeTest.php
check browser 'expected path [/probe-wrong]' vendor/bin/pest tests/Browser --compact
cp "$backup_dir/SmokeTest.php" tests/Browser/SmokeTest.php

leftovers="$(git status --short | grep -iE 'probe' || true)"
if [[ -n "$leftovers" ]]; then
    echo "FAIL  cleanup: probe files remain"
    echo "$leftovers"
    failures=$((failures + 1))
fi

echo
if [[ $failures -eq 0 ]]; then
    echo "All families engaged."
else
    echo "$failures check(s) failed."
fi
exit $((failures > 0 ? 1 : 0))
