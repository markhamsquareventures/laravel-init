# Dev processes

`composer run dev` runs `php artisan dev`. Laravel 13 starts the server, Vite, `pail` and `queue:listen`. Register extra processes with `Illuminate\Foundation\DevCommands::artisan()` in `AppServiceProvider`. Do not edit the composer `dev` script, and do not add a Procfile.
