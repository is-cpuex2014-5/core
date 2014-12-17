#include <cstdio>

int main() {
	int pc=-1;
	char rd;
	int scnt=0;
	int icnt=0;
	int value=0;
	char inst[9];
	inst[8]='\0';
	while(scanf("%c",&rd)!=EOF) {
		if(rd=='0') {
			value += value;
			scnt++;
		}
		if(rd=='1') {
			value += value + 1;
			scnt++;
		}
		if(scnt==4) {
			scnt=0;
			if(value>9) {
				inst[icnt]='A'+(char)(value-10);
			} else {
				inst[icnt]='0'+(char)value;
			}
			value=0;
			icnt++;
			if(icnt==8) {
				pc++;
				printf("if first_state_sram_input_id = %d then\n\tsram_write <= x\"%s\";\nend if;\n",pc,inst);
				icnt=0;
			}
		}
	}
	return 0;
}

