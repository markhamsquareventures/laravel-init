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
                            message: 'Do not set prefetch on Link.',
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
                            message: 'No prefetch on DOM.',
                        },
                    ],
                },
            ],
            'no-restricted-globals': [
                'error',
                {
                    name: 'setInterval',
                    message: 'Use a hook instead of setInterval.',
                },
            ],
            'no-restricted-properties': [
                'error',
                {
                    object: 'window',
                    property: 'setInterval',
                    message: 'Use a hook instead of window.setInterval.',
                },
            ],
        },
        options: {
            denyWarnings: true,
            typeAware: true,
        },
    },
