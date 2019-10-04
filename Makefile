build:
	docker pull sagemath/sagemath-jupyter
start:
	docker run -it -v "${PWD}/src":/home/sage -p 8888:8888 sagemath/sagemath-jupyter
