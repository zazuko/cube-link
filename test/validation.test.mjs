import approvals from 'approvals'
import { resolve } from 'path'
import { validateCube } from '../validate.js'
import factory from 'rdf-ext'
import fromFile from 'rdf-utils-fs/fromFile.js'

const loadDataset = async filePath =>
    factory.dataset().import(fromFile(filePath))

const dirname = resolve('test', 'support', 'approvals')

const basicCubeConstraint = await loadDataset('validation/basic-cube-constraint.ttl')
const standaloneConstraintConstraint = await loadDataset('validation/standalone-constraint-constraint.ttl')

const runTest = shapes => async name => {
    const cube = await loadDataset(`test/support/${name}.ttl`)
    const report = await validateCube(cube, shapes)
    approvals.verify(dirname, name, report.dataset.toCanonical())
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
]

describe('standalone constraint constraint', () => {
    runTests(standaloneConstraintConstraint, examples)
})

describe('observation validation', () => {
    for (const name of examples) {
        const testName = `data.${name}`
        it(testName, async () => {
            const cubeWithShape = await loadDataset(`test/support/${name}.ttl`)
            const report = await validateCube(cubeWithShape, cubeWithShape)
            approvals.verify(dirname, testName, report.dataset.toCanonical())
        })
    }
})