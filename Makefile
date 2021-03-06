default:
	bash go.sh

install_dependencies:
	sudo apt-get -y install mencoder
	./make_latest_flam3.sh

clean:
	rm -rf animated_genomes/
	rm -rf frames/

playlist:
	bash playlist.sh

play:
	mplayer -playlist movies/playlist.m3u
