'use strict'

module.exports = function rent (renderFn, state) {
  if (typeof renderFn !== 'function') {
    throw new TypeError('render must be a function, got ' + renderFn)
  }

  return function render () {
    var currentState = typeof state === 'function' ? state() : state
    return renderFn(currentState)
  }
}
