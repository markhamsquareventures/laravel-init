// Merge into the lint block of vite.config.ts. Keep the starter's ignorePatterns.
// The plugins list overwrites the defaults, so it must name every plugin.
// jsx-a11y/no-autofocus stays on (default). Format vite.config.ts with vp fmt after the merge.
    lint: {
        ignorePatterns: [
            'vendor/**',
            'node_modules/**',
            'public/**',
            'bootstrap/ssr/**',
            'tailwind.config.js',
            'resources/js/actions/**',
            'resources/js/components/ui/*',
            'resources/js/routes/**',
            'resources/js/wayfinder/**',
        ],
        jsPlugins: ['@shadcn/lint'],
        plugins: ['typescript', 'unicorn', 'oxc', 'react', 'jsx-a11y'],
        rules: {
            'shadcn/no-restyle': ['error', { allow: ['layout'] }],
            'shadcn/no-raw-colors': 'error',
            'shadcn/no-arbitrary-values': 'error',
            'shadcn/no-inline-styles': 'error',
            'shadcn/no-unknown-classes': 'error',
            'shadcn/require-static-classes': 'error',
            'no-unused-vars': 'error',
            'jsx-a11y/alt-text': 'error',
            'jsx-a11y/label-has-associated-control': 'error',
            'jsx-a11y/no-static-element-interactions': 'error',
            'jsx-a11y/control-has-associated-label': 'error',
            'react/jsx-no-target-blank': 'error',
            'react/forbid-component-props': [
                'error',
                {
                    forbid: [
                        {
                            propName: 'prefetch',
                            message: 'Do not prefetch links. Prefetching is usually more trouble than it is worth.',
                        },
                    ],
                },
            ],
            'react/forbid-dom-props': [
                'error',
                {
                    forbid: [
                        {
                            propName: 'prefetch',
                            message: 'Do not prefetch links. Prefetching is usually more trouble than it is worth.',
                        },
                    ],
                },
            ],
            'no-restricted-globals': [
                'error',
                {
                    name: 'setInterval',
                    message: 'Use Inertia usePoll, not setInterval.',
                },
            ],
            'no-restricted-properties': [
                'error',
                {
                    object: 'window',
                    property: 'setInterval',
                    message: 'Use Inertia usePoll, not setInterval.',
                },
            ],
        },
        options: {
            denyWarnings: true,
            typeAware: true,
        },
    },
