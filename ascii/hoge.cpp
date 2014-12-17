#include <cstdio>

int main() {
	int bs=(1<<20)/3;
	for(int i=0;i<8;i++) {
		if(bs%16 > 9) {
			printf("%c",'A'+(char)(bs%16-10));
		} else {
			printf("%c",'0'+(char)(bs%16));
		}
		bs/=16;
	}
	bs=(1<<21)/3;
	printf("\n");
	for(int i=0;i<8;i++) {
		if(bs%16 > 9) {
			printf("%c",'A'+(char)(bs%16-10));
		} else {
			printf("%c",'0'+(char)(bs%16));
		}
		bs/=16;
	}
	printf("\n");
	return 0;
}

