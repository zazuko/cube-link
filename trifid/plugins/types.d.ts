// `@rdfjs/formats-common` does not ship its own type declarations, which makes
// TypeScript (under `noImplicitAny`) complain about the import in `docs.js`.
// This minimal declaration describes the small surface we actually use.
declare module '@rdfjs/formats-common' {
  import type { Stream } from '@rdfjs/types'

  export const parsers: {
    import: (mediaType: string, input: unknown, options?: unknown) => Stream
  }
  export const serializers: {
    import: (mediaType: string, input: unknown, options?: unknown) => unknown
  }
}
