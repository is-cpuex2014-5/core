#include <cstdio>
#include <cstdlib>

int main(int argc,char **argv) {
	FILE *fp = fopen(argv[1],"rb");
	char rd;
	while(fscanf(fp,"%c",&rd)!=EOF) {
		for(int i=7;i>=0;i--) {
			if(rd&(1<<i)) {
				printf("1");
			} else {
				printf("0");
			}
		}
	}
	return 0;
}

