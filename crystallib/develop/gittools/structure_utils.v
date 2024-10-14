module gittools

// Helper function to filter by name, account, and provider.
fn is_repo_matches(repo GitRepo, args ReposGetArgs) bool {
	return (args.name.len == 0 || repo.name.to_lower() == args.name) &&
	(args.account.len == 0 || repo.account.to_lower() == args.account) &&
	(args.provider.len == 0 || repo.provider.to_lower() == args.provider)
}

