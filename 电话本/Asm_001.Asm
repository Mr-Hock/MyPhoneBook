.386 ; 说明程序运行的CPU平台. 
.model stdcall, flat ; 模式:1. stdcall函数的默认调用约定, 
option casemap:none ; 选项 :大小写敏感 
include msvcrt.inc     ; include 包含头文件, msvcrt.inc: c运行时库的头文件
include windows.inc  
include kernel32.inc  
includelib msvcrt.lib ; includelib 包含库文件,msvcrt.lib:c运行时库的二进制文件

.data  ; 伪指令 . 用于定义一个数据段,保存全局变量的定义

CONTACUSSTRUCT struct 
szName db 25 dup(0)
szPhNumber db 12 dup(0)
CONTACUSSTRUCT ends

g_stContacts CONTACUSSTRUCT 100 dup(<"0">)
g_nCount dd 0
g_nCountMax dd 100
g_strTemContacts CONTACUSSTRUCT <"0","0">

g_szScanfFormat db  "%s %s",0
g_szScanfName db "%s",0
g_szScanfPhNumber db "%s",0
g_szScanfMenu db "%d",0

g_Welcome db  "欢迎使用Mr.Hock电话本！",0dh,0ah,0
g_Title db  "title 欢迎使用Mr.Hock电话本！",0dh,0ah,0
g_Color db  "color 0a",0dh,0ah,0

g_Menu db 0dh,0ah,"====================",0dh,0ah,"1：添加电话号码",0dh,0ah,"2：查找电话号码",0dh,0ah,"3：修改电话号码",0dh,0ah,"4：删除电话号码",0dh,0ah,"5：查看所有电话号码",0dh,0ah,"6：退出电话本",0dh,0ah,"====================",0dh,0ah,0
g_ErrorMenu db  "输入菜单有误！",0dh,0ah,0dh,0ah,0
g_FunTable dd _Add,_Find,_Change,_Delete,_PrintAll,_End

g_Cls db  "cls",0

g_Str0 db  "请输入姓名 电话号码：",0dh,0ah,0
g_Str1 db  "请输入查询的名字：",0dh,0ah,0
g_Str2 db  "查询到电话号码：%s",0dh,0ah,0
g_Str3 db "添加操作成功！",0dh,0ah,0
g_Str4 db "未找到数据！",0dh,0ah,0
g_Str5 db "修改操作成功！",0dh,0ah,0
g_Str6 db  "请输入名字：",0dh,0ah,0
g_Str7 db  "请输入要修改的电话号码：",0dh,0ah,0
g_Str8 db  "删除操作成功！",0dh,0ah,0
g_Str9 db  "********************************",0dh,0ah,0
g_Str10 db  "姓名：%s 电话号码：%s",0dh,0ah,0
g_Str11 db  "名字过长！",0dh,0ah,0
g_Str12 db  "电话号码过长！",0dh,0ah,0

g_FilePath db "Phone.txt",0
g_FileModeR db "rb",0
g_FileModeW db "wb",0
g_FileHandle dd 0
 
;.const : ;常量数据段
 
.code ; 伪指令
SYSTEM_STRLEN proc  nData	;封装取字符串长度函数
	push  nData
	call crt_strlen
	add esp,4
	ret 4
SYSTEM_STRLEN endp

SYSTEM_PRINTF proc  nData	;封装打印函数
	push  nData
	call crt_printf
	add esp,4
	ret 4
SYSTEM_PRINTF endp

SYSTEMP_WELCOME proc	;打印欢迎界面

	invoke SYSTEM_PRINTF,offset g_Welcome
	
	push offset g_Title
	call crt_system
	add esp,4
	
	push offset g_Color
	call crt_system
	add esp,4

	ret

SYSTEMP_WELCOME endp

SYSTEM_CLS proc		;清屏
	
	push offset g_Cls
	call crt_system
	add esp,4
	
	ret

SYSTEM_CLS endp

SELECT_USER proc nName	;查找名字位置

	xor ecx,ecx
_LOOP:
	cmp ecx,g_nCount
	jne @f
	mov eax,-1
	ret 4
@@:
	lea esi,[g_stContacts]
	mov edi,nName
	mov eax,sizeof(CONTACUSSTRUCT)
	imul eax,ecx
	add esi,eax
	
	mov eax,ecx
	mov ecx,6
	repe cmpsd [esi],[edi]
	je @f
	mov ecx,eax
	inc ecx
	jmp _LOOP

@@:
	ret 4

SELECT_USER endp

ADD_USER proc		;增加电话号码
	
	push eax
	push ebx
	
	invoke SYSTEM_PRINTF,offset g_Str0
	
	
	lea eax,[g_strTemContacts.szPhNumber]
	lea ebx,[g_strTemContacts.szName]
	
	push eax
	push ebx
	push offset g_szScanfFormat
	call crt_scanf
	add esp,0ch
	
	lea eax,[g_strTemContacts.szName]
	invoke SYSTEM_STRLEN,eax
	cmp eax,25
	jb @f
	invoke SYSTEM_PRINTF,offset g_Str11
	pop ebx
	pop eax
	ret
@@:
	lea eax,[g_strTemContacts.szPhNumber]
	invoke SYSTEM_STRLEN,eax
	cmp eax,12
	jb @f
	invoke SYSTEM_PRINTF,offset g_Str12	
	pop ebx
	pop eax
	ret
@@:
	lea esi,[g_stContacts]
	mov ecx,g_nCount
	mov eax,sizeof(CONTACUSSTRUCT)
	imul eax,ecx
	add esi,eax
	
	mov ecx,37
	lea edi,[esi+CONTACUSSTRUCT.szName]
	lea esi,[g_strTemContacts.szName]
	rep movsb
	
	invoke SYSTEM_PRINTF,offset g_Str3
	inc g_nCount

	pop ebx
	pop eax
	ret

ADD_USER endp

FIND_USER proc		;查找电话号码
	
	invoke SYSTEM_PRINTF,offset g_Str1
	
	push offset g_strTemContacts.szName
	push offset g_szScanfName
	call crt_scanf
	add esp,08h
	
	
	push offset g_strTemContacts.szName
	call SELECT_USER
	cmp eax,-1
	jne @f
	invoke SYSTEM_PRINTF,offset g_Str4
	ret

@@:
	mov ecx,eax
	lea esi,[g_stContacts]
	mov ebx,sizeof(CONTACUSSTRUCT)
	imul ebx,ecx
	add esi,ebx
	lea eax,[esi+CONTACUSSTRUCT.szPhNumber]
	push eax
	push offset g_Str2
	call crt_printf
	add esp,08h
	ret
FIND_USER endp

CHANGE_USER proc		;修改电话号码
	push ebp
	mov ebp,esp
	sub esp,4
	invoke SYSTEM_PRINTF,offset g_Str6

	push offset g_strTemContacts.szName
	push offset g_szScanfName
	call crt_scanf
	add esp,08h
	
	push offset g_strTemContacts.szName
	call SELECT_USER
	cmp eax,-1
	jne @f
	invoke SYSTEM_PRINTF,offset g_Str4
	mov esp,ebp
	pop ebp
	ret

@@:	
	mov [ebp-4],eax

	invoke SYSTEM_PRINTF,offset g_Str7

	lea eax,[g_strTemContacts.szPhNumber]
	push eax
	push offset g_szScanfPhNumber
	call crt_scanf
	add esp,08h
	
	lea eax,[g_strTemContacts.szPhNumber]
	invoke SYSTEM_STRLEN,eax
	cmp eax,12
	jb @f
	invoke SYSTEM_PRINTF,offset g_Str12
	mov esp,ebp
	pop ebp
	ret
@@:
	mov ecx,[ebp-4]
	lea esi,[g_stContacts]
	mov ebx,sizeof(CONTACUSSTRUCT)
	imul ebx,ecx
	add esi,ebx
	
	mov ecx,12
	lea edi,[esi+CONTACUSSTRUCT.szPhNumber]
	lea esi,[g_strTemContacts.szPhNumber]
	rep movsb
	
	
	invoke SYSTEM_PRINTF,offset g_Str5

	mov esp,ebp
	pop ebp
	ret

CHANGE_USER endp

DELETE_USER proc		;删除电话号码
		
	invoke SYSTEM_PRINTF,offset g_Str6
	
	push offset g_strTemContacts.szName
	push offset g_szScanfName
	call crt_scanf
	add esp,08h
	
	push offset g_strTemContacts.szName
	call SELECT_USER
	cmp eax,-1
	jne @f
	invoke SYSTEM_PRINTF,offset g_Str4
	ret

@@:
	mov ecx,eax
	lea edi,[g_stContacts]
	mov ebx,sizeof(CONTACUSSTRUCT)
	imul ebx,ecx
	add edi,ebx
	mov esi,edi
	mov ebx,sizeof(CONTACUSSTRUCT)
	add esi,ebx
	inc ecx
	
	mov eax,g_nCount
	sub eax,ecx
	mov ebx,sizeof(CONTACUSSTRUCT)
	imul ebx,eax
	mov ecx,ebx
	rep movs byte ptr [edi],byte ptr [esi]

	mov ebx,sizeof(CONTACUSSTRUCT)
	push ebx
	push 0
	push edi
	call crt_memset
	add esp,0ch
	dec g_nCount
	 
	invoke SYSTEM_PRINTF,offset g_Str8

	ret

DELETE_USER endp

PRINTALL_USER proc	;遍历所有电话号码

	invoke SYSTEM_PRINTF,offset g_Str9
	cmp g_nCount,0
	jne @f
	invoke SYSTEM_PRINTF,offset g_Str4
	invoke SYSTEM_PRINTF,offset g_Str9
	ret 
		
@@:	
	xor ecx,ecx
	
_LOOP:
	push ecx
	lea esi,[g_stContacts]
	mov eax,sizeof(CONTACUSSTRUCT)
	imul eax,ecx
	add esi,eax
	
	lea eax,[esi+CONTACUSSTRUCT.szPhNumber]
	push eax
	lea eax,[esi+CONTACUSSTRUCT.szName]
	push eax
	push offset g_Str10
	call crt_printf
	add esp,0ch
	pop ecx

	inc ecx
	cmp ecx,g_nCount
	jne _LOOP

	invoke SYSTEM_PRINTF,offset g_Str9
	ret 

PRINTALL_USER endp

fopen proc nMode:DWORD	;打开文件，模式0=读 模式1=写
	
	cmp nMode,0
	jne @f
	push offset g_FileModeR
	jmp _Open
@@:
	push offset g_FileModeW
_Open:	
	push offset g_FilePath
	call crt_fopen
	add esp,8
	mov g_FileHandle,eax

	ret 4
fopen endp

fclose proc		;关闭文件
	push ebp
	mov ebp,esp
	push g_FileHandle
	call crt_fclose
	add esp,4
	leave
	ret
fclose endp

fwrite proc		;写出文件数据
	push ebp
	mov ebp,esp
	
	push g_FileHandle
	push g_nCount
	push sizeof(CONTACUSSTRUCT)
	push offset g_stContacts
	call crt_fwrite
	
	add esp,010h
	leave
	ret
fwrite endp

fread proc			;读入文件数据
	push ebp
	mov ebp,esp
	
	push g_FileHandle
	push g_nCountMax
	push sizeof(CONTACUSSTRUCT)
	push offset g_stContacts
	call crt_fread
	
	add esp,010h
	
	mov g_nCount,eax
	
	leave
	ret
fread endp

SAVEDATA proc		;保存电话号码数据
	invoke fopen,1
	call fwrite
	call fclose
	ret

SAVEDATA endp

OPENDATA proc		;读入电话号码数据
	invoke fopen,0
	call fread
	call fclose
	ret

OPENDATA endp

_main:

	call OPENDATA				;读取保存的电话本数据
	call SYSTEMP_WELCOME			;打印欢迎界面
	
	push ebp 					;打开栈帧
	mov ebp,esp
	sub esp,4					;声明局部变量
	
@@:
	invoke SYSTEM_PRINTF,offset g_Menu		;打印菜单
	
	lea eax,[ebp-4]				;保存用户输入的菜单编号到[ebp-4]局部变量
	push eax
	push offset g_szScanfMenu
	call crt_scanf				;等待用户输入菜单
	add esp,8
	
	call SYSTEM_CLS				;清屏

	mov eax,[ebp-4]				;将菜单编号放入EAX
	dec eax					;自减1
	cmp eax,-1
	je _MenuError				;如果=-1就跳到打印错误菜单
	jmp [g_FunTable+eax*4]			;否则根据跳转表进行跳转
	
_MenuError:					;打印错误菜单
	invoke SYSTEM_PRINTF,offset g_ErrorMenu
	jmp @b					;往回跳到@@最近的一个标号
	
_Add:
	call ADD_USER
	call SAVEDATA
	jmp @b
_Find:	
	call FIND_USER
	jmp @b
_Change:	
	call CHANGE_USER
	call SAVEDATA
	jmp @b
_Delete:
	call DELETE_USER
	call SAVEDATA
	jmp @b
_PrintAll:
	call PRINTALL_USER
	jmp @b
_End:
	mov esp,ebp
	pop ebp
	ret	
end _main
end
























































































