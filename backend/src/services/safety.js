const minClearanceCm = 55;

export function evaluateSafeDirections(telemetry) {
  const aqiPenalty = getAqiPenalty(telemetry.aqi);
  const directions = [
    ['front', telemetry.front],
    ['right', telemetry.right],
    ['left', telemetry.left],
    ['back', telemetry.back],
  ].map(([direction, clearance]) => {
    const blocked = clearance < minClearanceCm;
    const clearanceScore = Math.min(60, Math.round(clearance / 4));
    return {
      direction,
      clearance_cm: clearance,
      blocked,
      aqi: normalizeAqi(telemetry.aqi),
      score: blocked ? 0 : Math.max(0, 100 - aqiPenalty + clearanceScore - 25),
    };
  });

  return directions.sort((a, b) => b.score - a.score);
}

function getAqiPenalty(aqi) {
  switch (normalizeAqi(aqi)) {
    case 'GOOD':
      return 0;
    case 'DANGEROUS':
      return 45;
    default:
      return 20;
  }
}

function normalizeAqi(aqi) {
  return aqi === 'HIGH' || aqi === 'POOR' ? 'DANGEROUS' : aqi;
}
