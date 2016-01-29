require 'kitchen/driver/docker'

module Kitchen
  module Driver
    class Docker < Kitchen::Driver::SSHBase
      def rm_container(state)
        container_id = state[:container_id]
        docker_command("exec #{container_id} shutdown now")
        docker_command("wait #{container_id}")
        docker_command("rm #{container_id}")
      end
    end
  end
end
