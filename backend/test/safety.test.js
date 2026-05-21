import assert from 'node:assert/strict';
import { describe, it } from 'node:test';

import { evaluateSafeDirections } from '../src/services/safety.js';

describe('evaluateSafeDirections', () => {
  it('blocks short-clearance paths and ranks the safest direction first', () => {
    const result = evaluateSafeDirections({
      aqi: 'GOOD',
      front: 40,
      left: 100,
      right: 230,
      back: 120,
    });

    assert.equal(result[0].direction, 'right');
    assert.equal(result.find((item) => item.direction === 'front').blocked, true);
  });
});
