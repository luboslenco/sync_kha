var project = new Project('sync_kha');

if (platform === Platform.iOS) {
	project.addFile('ios/synckore/**');
	project.addIncludeDir('ios/synckore');
}

return project;
