import config from '@tpluscode/eslint-config/js'

export default [
  ...config,
  {
    // The default `node` import resolver does not understand the `exports`
    // field used by some ESM-only dependencies (e.g. `node-fetch-cache`).
    // The TypeScript resolver does, and works for plain JavaScript too.
    settings: {
      'import/resolver': {
        typescript: true,
        node: true,
      },
    },
  },
]
