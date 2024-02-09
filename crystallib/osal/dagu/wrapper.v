module dagu

import os
import freeflowuniverse.crystallib.osal

@[params]
pub struct CompletionBashOptions {
	no_descriptions ?bool // disable completion descriptions
}

// Generate the autocompletion script for bash
pub fn completion_bash(options CompletionBashOptions) !string {
	flags := osal.write_flags[CompletionBashOptions](options)
	result := os.execute_opt('dagu completion ${flags}')!
	return result.output
}

@[params]
pub struct CompletionFishOptions {
	no_descriptions ?bool // disable completion descriptions
}

// Generate the autocompletion script for fish
pub fn completion_fish(options CompletionFishOptions) !string {
	flags := osal.write_flags[CompletionFishOptions](options)
	result := os.execute_opt('dagu completion fish ${flags}')!
	return result.output
}

@[params]
pub struct CompletionPowershellOptions {
	no_descriptions ?bool // disable completion descriptions
}

// Generate the autocompletion script for powershell
pub fn completion_powershell(options CompletionPowershellOptions) !string {
	flags := osal.write_flags[CompletionPowershellOptions](options)
	result := os.execute_opt('dagu completion powershell ${flags}')!
	return result.output
}

@[params]
pub struct CompletionZshOptions {
	no_descriptions ?bool // disable completion descriptions
}

// Generate the autocompletion script for zsh
pub fn completion_zsh(options CompletionZshOptions) !string {
	flags := osal.write_flags[CompletionZshOptions](options)
	result := os.execute_opt('dagu completion zsh ${flags}')!
	return result.output
}

@[params]
pub struct DryOptions {
	params string // parameters
}

// Dry-runs specified DAG
pub fn dry(dag_file string, options DryOptions) !string {
	flags := osal.write_flags[DryOptions](options)
	result := os.execute_opt('dagu dry  ${dag_file} ${flags}')!
	return result.output
}

// Help about any command
pub fn help() !string {
	result := os.execute_opt('dagu help')!
	return result.output
}

// Restart the DAG
pub fn restart(dag_file string) !string {
	result := os.execute_opt('dagu restart ${dag_file}')!
	return result.output
}

// Retry the DAG execution
pub fn retry(request_id string, dag_file string, req string) !string {
	result := os.execute_opt('dagu retry --req ${request_id} ${dag_file}')!
	return result.output
}

@[params]
pub struct SchedulerOptions {
	dags ?string // location of DAG files (default is /Users/<user>/.dagu/dags)
}

// Start the scheduler
pub fn scheduler(options SchedulerOptions) !string {
	flags := osal.write_flags[SchedulerOptions](options)
	result := os.execute_opt('dagu scheduler ${flags}')!
	return result.output
}

@[params]
pub struct ServerOptions {
	dags ?string // location of DAG files (default is /Users/<user>/.dagu/dags)
	host ?string // server host (default is localhost)
	port ?string // server port (default is 8080)
}

// Start the server
pub fn server(options ServerOptions) !string {
	flags := osal.write_flags[ServerOptions](options)
	result := os.execute_opt('dagu server ${flags}')!
	return result.output
}

// Start the server
pub fn server_bg(options ServerOptions) !string {
	flags := osal.write_flags[ServerOptions](options)
	result := os.execute_opt('& dagu server ${flags}')!
	return result.output
}

@[params]
pub struct StartOptions {
	params ?string // parameters
}

// Runs the DAG
pub fn start(dag_file string, options StartOptions) !string {
	flags := osal.write_flags[StartOptions](options)
	println('debugzo: dagu start  ${dag_file} ${flags}')
	result := os.execute_opt('dagu start  ${dag_file} ${flags}')!
	return result.output
}

@[params]
pub struct StartAllOptions {
	dags string // location of DAG files (default is /Users/<user>/.dagu/dags)
	host string // server host (default is localhost)
	port string // server port (default is 8080)
}

// Launches both the Dagu web UI server and the scheduler process.
pub fn start_all(options StartAllOptions) !string {
	flags := osal.write_flags[StartAllOptions](options)
	result := os.execute_opt('dagu start-all ${flags}')!
	return result.output
}

// Display current status of the DAG
pub fn status(dag_file string) !string {
	result := os.execute_opt('dagu status ${dag_file}')!
	return result.output
}

// Stop the running DAG
pub fn stop(dag_file string) !string {
	result := os.execute_opt('dagu stop ${dag_file}')!
	return result.output
}

// Display the binary version
pub fn version() !string {
	result := os.execute_opt('dagu version')!
	return result.output
}
