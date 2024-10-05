; edge detection via sobel filters
; works on good old 3 channel .bmp files
; COMPILING 
; nasm -fwin64 -o edge_detection.obj edge_detection.asm
; gcc -o edge_detection.exe edge_detection.obj
;
; USAGE
; edge_detection.exe input.bmp output.bmp



default rel
extern fopen,fseek,fwrite,fread,fclose
extern malloc, free
global main
section .data
	; режими роботи з файлами
	rb db "rb",0x0
	wb db "wb",0x0
	; комірка пам'яті для обчислення кореня числа
	temp dq 0.0
	; матриці для фільтра Собеля
	sobel_x: 
	dd  1, 2, 1, 
	dd  0, 0, 0, 
	dd -1,-2,-1
	sobel_y:
	dd  1, 0,-1, 
	dd  2, 0,-2,
	dd  1, 0,-1 
section .text
main:
	; зберігаємо значення регістрів та виділяємо пам'ять
	push	r12
	push 	rsi
	push 	rdi
	push 	rbp
	mov 	rbp, rsp
	sub 	rsp, 32
	
	; при неправильній кількості аргументів - вийти з програми
	cmp rcx, 3
	jne .exit
	
	mov r12, rdx
	
	; завантажуємо растрове зображення у масив пікселів
	mov		rcx,[r12 + 8]
	lea 	rdx,[rbp - 16]
	lea 	r8,[rbp - 8]
	call 	loadImage
	mov 	rsi, rax
	; застосовуємо фільтр до масиву
	mov 	rcx, rax
	mov 	edx,dword[rbp - 16]
	mov 	r8d,dword[rbp - 8]
	call 	sobel_filter
	mov 	rdi, rax
	; звільняємо масив пікселів оригінального зображення
	mov 	rcx, rsi
	call 	free
	; перетворюємо кольорове зображення у чорно-біле
	mov 	rcx, rdi
	imul 	edx, dword[rbp - 16],3
	imul 	edx,dword[rbp - 8]
	call 	grayscale
	; створюємо новий файл та записуємо в нього новий масив пікселів
	mov		rcx,[r12 + 16]
	mov 	rdx,rdi
	mov 	r8d,dword[rbp - 16]
	mov 	r9d,dword[rbp - 8]
	call 	saveImage

.exit:
	; звільняємо пам'ять та регістри
	add 	rsp, 32
	mov 	rsp, rbp
	pop 	rbp
	pop 	rdi
	pop 	rsi
	pop		r12
	ret
; функція збереження растрового зображення
saveImage:
	; збергігаємо значення регістрів та виділяємо пам'ять
	push	rsi
	push	rdi
	push	rbx
	push	r12
	push	rbp
	mov		rbp,rsp
	sub		rsp,104
	; зберігаємо вказівник на масив пікселів,ширину та висоту
	mov		rsi,rdx
	mov		edi,r8d
	mov		ebx,r9d
	; відкриваємо файл для запису
	lea		rdx,[wb] 
	call	fopen
	mov		r12,rax
	; записуємо заголовок растрового зображення у пам'ять
	mov		 word[rbp - 64], 0x4d42
	mov		qword[rbp - 62], 0
	mov 	dword[rbp - 54], 54
	mov 	dword[rbp - 50], 40
	mov 	dword[rbp - 46], edi
	mov 	dword[rbp - 42], ebx
	mov		 word[rbp - 38], 1
	mov  	 word[rbp - 36], 24
	mov 	qword[rbp - 34], 0
	mov 	qword[rbp - 26], 0
	mov 	qword[rbp - 18], 0
	; записуємо заголовок
	lea		rcx, [rbp - 64]
	mov		edx, 54
	mov		r8d, 1
	mov		r9 , r12
	call	fwrite
	; записуємо масив піскелів
	mov		rcx, rsi
	imul	edx, ebx,3
	imul	edx, edi
	mov		r8d, 1
	mov		r9 , r12
	call	fwrite
	;закриваємо файл
	mov		rcx,r12
	call	fclose
	; звільняємо регістри та пам'ять
	add		rsp, 104
	mov		rsp, rbp
	pop		rbp
	pop		r12
	pop		rbx
	pop		rdi
	pop		rsi
	ret
; функція завантаження растрового зображення
loadImage:
	; зберігаємо значення регістрів та виділяємо місце на стеку
	push 	rsi
	push 	rdi
	push 	rbx
	push 	rbp
	mov 	rbp, rsp
	sub 	rsp,48
	;зберігаємо вказівники на ширину та висоту зображення
	mov 	rsi, rdx
	mov 	rdi, r8
	; відкриваємо файл для читання
	lea 	rdx,[rb]
	call 	fopen
	mov 	rbx, rax
	; переходимо до потрібного місця у файлі
	mov 	rcx, rbx
	mov 	edx, 10
	xor 	r8d, r8d
	call 	fseek
	; зчитуємо дані з файлу
	lea 	rcx,[rbp - 5*4]
	mov 	edx ,4
	mov 	r8d, 4
	mov 	r9, rbx
	call 	fread
	; повертаємо висоту та ширину зображення через вказівники
	mov 	eax, dword[rbp - 3*4]
	mov 	dword[rsi], eax
	mov 	ecx, dword[rbp - 2*4]
	mov 	dword[rdi], ecx
	; обчислюємо загальний розмір зображення та виділяємо пам'ять
	imul 	ecx, eax
	imul 	ecx, 3
	mov 	esi, ecx
	movsx 	rcx, ecx
	call 	malloc
	mov  	rdi, rax
	; переходимо до місця розміщення пікселів у файлі
	mov	 	rcx, rbx
	mov 	edx, dword[rbp - 5*4]
	xor 	r8d, r8d
	call 	fseek
	; зчитуємо пікселі
	mov 	rcx, rdi
	mov 	edx, esi
	mov 	r8d, 1
	mov 	r9, rbx
	call 	fread
	; закриваємо файл та повертаємо вказівник на масив з пікселями
	mov 	rcx, rbx
	call 	fclose
	mov 	rax, rdi
	; звільнюємо стек та повертаємо регістри
	add 	rsp,48
	mov 	rsp, rbp
	pop 	rbp
	pop 	rbx
	pop 	rdi
	pop 	rsi
	ret
; функція знаходження кореня числа
sqroot:
	; завантаження числа у комірку пам'яті
	mov dword[temp], ecx
	;завантаження числа у математичний співпроцесор
	fild 	dword[temp]
	; обчислення кореня
	fsqrt
	; завантаження кореня у комірку пам'яті
	fistp 	dword[temp]
	; перетворення на ціле число
	mov eax, dword[temp]
	ret
sobel_filter:
	; зберігаємо значення регістрів на стеку та виділяємо пам'ять
	push 	r13
	push 	r12
	push 	rbx
	push 	rdi
	push 	rsi
	push 	rbp
	mov 	rbp, rsp
	sub 	rsp, 80
	; зберігаємо вказівник на масив пікселів
	mov 	rsi, rcx
	;зберігаємо ширину,висоту та розмір сторони вхідної матриці
	mov 	dword[rbp - 5*4], edx 
	mov 	dword[rbp - 4*4], r8d
	mov 	dword[rbp - 3*4], 3
	imul 	edx, r8d
	mov 	r12d, edx 
	; лічильник
	dec 	r12d
	; загальний розмір зображення
	imul 	edx, 3
	movsxd 	rcx, edx
	; виділяємо пам'ять для вихідного масиву пікселів
	call 	malloc 
	mov 	rdi, rax
	mov 	rcx, sobel_x
	mov 	edx, 3
	; знаходимо суму додатніх значень у матриці
	call 	k_positive_sum
	mov 	ebx, eax
.loop:
	mov 	eax, r12d
	cdq
	; (лічильник/ширина зображення)
	div 	dword[rbp - 5*4]
	; поточний рядок та стовпець у масиві пікселів
	mov 	dword[rbp - 2*4], eax 
	mov 	dword[rbp - 1*4], edx
	lea 	rcx,[rbp - 9*4] 
	mov 	rdx, rsi
	lea 	r8,[sobel_x]
	lea 	r9,[rbp - 5*4]
	 ; застосування матриці по x до поточного пікселя
	call 	convolution
	lea 	rcx,[rbp - 12*4] 
	mov 	rdx, rsi
	lea 	r8,[sobel_y]
	lea 	r9,[rbp - 5*4]
	; застосування матриці по y до поточного пікселя
	call 	convolution 
	lea 	rcx,[rbp - 9*4]
	mov 	edx,3
	mov 	r8d, ebx
	; змінюємо діапазон значень двох матриць
	call 	normalize
	lea 	rcx,[rbp - 12*4]
	mov 	edx,3
	mov 	r8d, ebx
	call 	normalize
	mov 	edx, dword[rbp - 5*4]
	imul 	edx, dword[rbp - 2*4]
	add 	edx, dword[rbp - 1*4]
	imul 	edx, 3
	movsx 	rdx, edx
	; поточний піксель у вихідному масиві
	lea 	r13,[rdi + rdx]
	; знаходимо значення червого,зеленого,синього та розміщуємо їх у вихідний масив
	mov 	ecx, dword[rbp - 9*4]
	imul 	ecx, ecx
	mov 	edx, dword[rbp - 12*4]
	imul 	edx, edx
	add 	ecx, ecx
	call 	sqroot
	mov 	byte[r13 + 0], al
	mov 	ecx, dword[rbp - 10*4]
	imul 	ecx, ecx
	mov 	edx, dword[rbp - 13*4]
	imul 	edx, edx
	add 	ecx, ecx
	call 	sqroot
	mov 	byte[r13 + 1], al
	mov 	ecx, dword[rbp - 11*4]
	imul 	ecx, ecx
	mov 	edx, dword[rbp - 14*4]
	imul 	edx, edx
	add 	ecx, ecx
	call 	sqroot
	mov 	byte[r13 + 2], al
	sub 	r12d, 1
	jnz 	.loop
	mov 	rax, rdi
	; звільняємо регістри та пам'ять
	add 	rsp, 80
	mov 	rsp, rbp
	pop 	rbp
	pop 	rsi
	pop 	rdi
	pop 	rbx
	pop 	r12
	pop 	r13
	ret
; змінюємо діапазон значень вхідної матриці
normalize:
	xor 	r10,r10
	movsxd 	r9,edx
.loop:
	xor 	eax, eax
	; множимо поточний елемент матриці на 255 та ділимо на необхідне значення в r8d
	imul 	eax, dword[rcx + r10*4],255
	cdq
	idiv 	r8d
	; розміщуємо нове значення у матриці
	mov 	dword[rcx + r10*4],eax
	inc 	r10
	cmp 	r10, r9
	jl 		.loop
	ret

; перетворюємо кольори зображення на відтінки сірого
grayscale:
	; зберігаємо вказівник на масив пікселів та розмір масиву
	mov 	r10, rcx
	movsxd 	r11, edx
.loop:
	; (червоний + синій + зелений) / 3
	movzx 	eax, byte[r10 + r11 - 0]
	movzx 	r8d, byte[r10 + r11 - 1]
	add 	eax,r8d
	movzx 	r8d, byte[r10 + r11 - 2]
	add 	eax,r8d
	mov 	r8d, 3
	cdq
	idiv 	r8d
	; змінюємо значення кольорів на середнє арифметичне
	mov 	byte[r10 + r11 - 0], al
	mov 	byte[r10 + r11 - 1], al
	mov 	byte[r10 + r11 - 2], al
	sub 	r11, 3
	jnz 	.loop
	ret
; знаходимо суму додатніх значень у матриці 
k_positive_sum:
	xor 	eax, eax
	imul 	edx, edx
	dec 	edx
	movsxd 	rdx,edx
.loop:
	cmp 	dword[rcx + rdx*4],0
	jle 	.skip
	add 	eax, dword[rcx + rdx*4]
.skip:
	sub 	edx,1
	jnz 	.loop
	imul	eax, 255
	ret
convolution:
	; зберігаємо значення регістрів та виділяємо пам'ять
	push	r13
	push	r12
	push	rdi
	push	rsi
	push	rbx
	push	rbp
	mov		rbp, rsp
	sub		rsp, 32
	; зберігаємо вказівник на масив пікселів та масив для результатів обчислень
	mov		rsi,rcx 
	mov		qword[rbp - 16], rdx
	mov		r11d,dword[r9 + 2*4]
	; обчислюємо та збергієамо розмір матриці
	movsxd	r10, r11d
	imul	r10, r10
	mov		qword[rbp - 24], r10
	; дістаємо ширину,висоту, поточний рядок та стовпець із вхідного масиву
	mov		ebx ,dword[r9 + 0*4] 
	mov		r10d,dword[r9 + 1*4] 
	mov		ecx ,dword[r9 + 3*4] 
	mov		r13d,dword[r9 + 4*4] 
	mov		eax,r11d
	; довжина сторони матриці / 2
	sar		eax, 1
	add		r13d,ebx
	add		ecx,r10d 
	; поточний рядок + висота - довжина сторони матриці / 2
	sub		ecx,eax 
	; поточний стовпець + ширина -  довжина сторони матриці / 2
	sub		r13d,eax
	mov		dword[rbp - 8],ecx
	xor		ecx,ecx
.loop:
	mov		eax,ecx
	mov		r11d,dword[r9 + 2*4]
	cdq
	idiv	r11d
	mov		r12d, eax
	mov		r11d, edx
	; індекс поточного елемента у масиві пікселів
	add		eax, dword[rbp - 8]
	cdq
	mov		r10d,dword[r9 + 1*4]
	idiv	r10d
	imul	edx,ebx
	mov		r10d,edx
	mov		eax, r13d
	add		eax, r11d
	cdq
	mov		ebx, dword[r9 + 0*4]
	idiv	ebx
	add		r10d, edx
	; індекс поточного елемента у вхідній матриці
	imul	r12d, dword[r9 + 2*4]
	add		r12d, r11d
	movsxd	r12, r12d
	imul 	eax,r10d,3
	cdqe
	; отримуємо значення червоного,зеленого,синього із масиву пікселів
	; та множимо та відповідне значення з матриці
	add		rax, qword[rbp - 16]
	movzx	edx,byte[rax + 0]
	imul	edx,dword[r8 + r12*4]
	add		dword[rsi + 0*4],edx
	movzx	edx,byte[rax + 1]
	imul	edx,dword[r8 + r12*4]
	add		dword[rsi + 1*4],edx
	movzx	eax,byte[rax + 2]
	imul	eax,dword[r8 + r12*4]
	add		dword[rsi + 2*4],eax
	inc		rcx
	cmp		rcx, qword[rbp - 24]
	jne		.loop
	; звільняємо пам'ять та регістри
	add		rsp, 32
	mov		rsp, rbp
	pop		rbp
	pop		rbx
	pop		rsi
	pop		rdi
	pop		r12
	pop		r13
	ret