# Periodic RSS/GC report, one line per process.
#
# Render's dashboard graph shows the *container* total, which is the sum of
# Thruster, Puma and (previously) the Solid Queue supervisor/dispatcher/worker.
# That single number cannot distinguish "one process is leaking" from "the
# baseline of five processes is simply larger than 512MB", and those have
# opposite fixes. This tags each line with the pid and process name so the two
# can be told apart in the Render log viewer.
#
# Cheap by design: one line per process every 5 minutes, no allocation
# profiling. Set MEMORY_REPORT=false to turn it off once the OOMs are settled.
if ENV.fetch("MEMORY_REPORT", "true") == "true" && !Rails.env.test?
  Rails.application.config.after_initialize do
    Thread.new do
      Thread.current.name = "memory-report"
      # Stagger slightly so forked children don't all report on the same tick.
      sleep 30 + (Process.pid % 30)

      loop do
        begin
          rss_kb =
            begin
              File.read("/proc/self/status")[/VmRSS:\s+(\d+)/, 1].to_i
            rescue StandardError
              0
            end

          stat = GC.stat
          Rails.logger.info(
            "[Memory] pid=#{Process.pid} name=#{$PROGRAM_NAME.split.first} " \
            "rss=#{(rss_kb / 1024.0).round(1)}MB " \
            "heap_live=#{stat[:heap_live_slots]} " \
            "old_objects=#{stat[:old_objects]} " \
            "major_gc=#{stat[:major_gc_count]} minor_gc=#{stat[:minor_gc_count]} " \
            "threads=#{Thread.list.size}"
          )
        rescue StandardError => e
          Rails.logger.error("[Memory] report failed: #{e.message}")
        end

        sleep 5.minutes
      end
    end
  end
end
