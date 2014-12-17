#include <cstdio>
#include <cstdlib>

int main(int argc,char **argv) {
	FILE *fp = fopen(argv[1],"rb");
	char rd;
    int pc=349525;
	int cnt[9];
	for(int i=0;i<5;i++) cnt[i]=5;
	char mes[99]="0123456789ABCDEF";
	while(fscanf(fp,"%c",&rd)!=EOF) {
		int ida=0;
		for(int i=7;i>=4;i--) {
			if(rd&(1<<i)) {
				ida+=(1<<(i-4));
			}
		}
		int idb=0;		
		for(int i=3;i>=0;i--) {
			if(rd&(1<<i)) {
				idb+=(1<<i);
			}
		}
		printf("if first_state_sram_input_id = %d then\n\tsram_write <= \"000000%c%c\"\nend if;\n",pc,mes[ida],mes[idb]);
		pc++;
	}
	return 0;
}

