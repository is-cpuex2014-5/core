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
				printf("if pc = %d then\n\tinst <= x\"%s\";\nend if;\n",pc*4,inst);
				icnt=0;
			}
		}
	}
	printf("if pc > %d then\n\tinst <= x\"FFFFFFFF\";\nend if;\n",pc*4);
	return 0;
}

