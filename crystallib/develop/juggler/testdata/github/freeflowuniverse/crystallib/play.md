# Juggler Test CI Play Script

!!dagu.configure
  instance: 'itenv_juggler'

!!dagu.new_dag
  name: 'deploy_playground'

!!dagu.add_step
  dag: 'deploy_playground'
  name: 'install_baobab'
  command: 'echo hello world'