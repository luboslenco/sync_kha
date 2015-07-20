var project = new Project('sync_kha');

if (platform === Platform.iOS) {
	project.addFile('ios/synckore/**');
	project.addIncludeDir('ios/synckore');
}
else if (platform === Platform.OSX) {
	project.addFile('osx/synckore/**');
	project.addIncludeDir('osx/synckore');
}

return project;
