import approvals from 'approvals'
import { resolve } from 'path'
import { validateCube } from '../validate.js'
import rdf from '@zazuko/env-node'
import formats from '@rdfjs-elements/formats-pretty'

rdf.formats.import(formats)

const loadDataset = async filePath =>
  rdf.dataset().import(rdf.fromFile(filePath))

const dirname = resolve('test', 'support', 'approvals')

const basicCubeConstraint = await loadDataset('validation/basic-cube-constraint.ttl')
const standaloneConstraintConstraint = await loadDataset('validation/standalone-constraint-constraint.ttl')

const prefixes = ['sh', 'rdf', 'schema', 'xsd', ['cube', 'https://cube.link/']]

const runTest = shapes => async name => {
    const cube = await loadDataset(`test/support/${name}.ttl`)
    const report = await validateCube(cube, shapes, rdf)
    approvals.verify(dirname, name, await report.dataset.serialize({ format: 'text/turtle', prefixes }))
}

const runTests = async (shape, names) => {
    const test = runTest(shape)
    for (const name of names) {
        it(name, async () => {
            await test(name)
        })
    }
}

describe('basic cube constraint', () => {
    runTests(basicCubeConstraint, [
        'basic.withoutObservationSet',
        'basic.withoutObservations',
        'basic.withoutProperties',
        'basic.valid'
    ])
})

const examples = [
    'undefinedNotAllowed',
    'undefinedAllowed',
    'undefinedOrBounded',
    'withoutName',
    'withoutType',
]

describe('standalone constraint constraint', () => {
    runTests(standaloneConstraintConstraint, examples)
})

describe('observation validation', () => {
    for (const name of examples) {
        const testName = `data.${name}`
        it(testName, async () => {
            const cubeWithShape = await loadDataset(`test/support/${name}.ttl`)
            const report = await validateCube(cubeWithShape, cubeWithShape, rdf)
            approvals.verify(dirname, testName, await report.dataset.serialize({ format: 'text/turtle', prefixes }))
        })
    }
})
