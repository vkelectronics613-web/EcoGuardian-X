import { createClient } from '@supabase/supabase-js';

export function createTelemetryStore() {
  const supabaseUrl = process.env.SUPABASE_URL;
  const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
  const supabase = supabaseUrl && supabaseKey ? createClient(supabaseUrl, supabaseKey) : null;
  const memory = [];

  return {
    async insertTelemetry(row) {
      memory.push(row);
      if (memory.length > 1000) memory.shift();
      if (!supabase) return;
      const { error } = await supabase.from('telemetry').insert({
        robot_id: row.robot_id,
        x: row.x,
        y: row.y,
        aqi: row.aqi,
        front_cm: row.front,
        left_cm: row.left,
        right_cm: row.right,
        back_cm: row.back,
        battery: row.battery,
        obstacle: row.obstacle,
        safe_directions: row.safe_directions,
        created_at: row.timestamp,
      });
      if (error) console.error('Supabase telemetry insert failed:', error.message);
    },

    async getHistory(robotId, limit = 200) {
      if (supabase) {
        const { data, error } = await supabase
          .from('telemetry')
          .select('*')
          .eq('robot_id', robotId)
          .order('created_at', { ascending: false })
          .limit(limit);
        if (!error) return data;
      }
      return memory.filter((row) => row.robot_id === robotId).slice(-limit).reverse();
    },
  };
}
