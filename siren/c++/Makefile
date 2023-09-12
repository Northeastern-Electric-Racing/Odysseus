CC=g++

all: main.o siren_server.o
	$(CC) main.o siren_server.o -o siren.bin -lcrypto

main.o: main.cpp siren_server.h
	$(CC) -c main.cpp

siren_server.o: siren_server.cpp siren_server.h
	$(CC) -c siren_server.cpp

clean:
	rm *.o *.bin