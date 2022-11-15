	.data
headMsg:	.asciz	"Start av testprogram. Skriv in 5 tal!"
endMsg:		.asciz	"Slut pa testprogram"
buf:		.space	64
outbufindex:	.quad	0
outbuf:		.space	64
inbufindex:	.quad	0
sum:		.quad	0
count:		.quad	0
temp:		.quad	0

	.text
	.global	main
main:
	pushq	$0
	movq	$headMsg,%rdi
	call	putText
	call	outImage
	call	inImage
	movq	$5,count
l1:
	call	getInt
	movq	%rax,temp
	cmpq	$0,%rax
	jge		l2
	call	getOutPos
	decq	%rax
	movq	%rax,%rdi
	call	setOutPos
l2:
	movq	temp,%rdx
	add	%rdx,sum
	movq	%rdx,%rdi
	call	putInt
	movq	$'+',%rdi
	call	putChar
	decq	count
	cmpq	$0,count
	jne	l1
	call	getOutPos
	decq	%rax
	movq	%rax,%rdi
	call	setOutPos
	movq	$'=',%rdi
	call	putChar
	movq	sum, %rdi
	call	putInt
	call	outImage
	movq	$12,%rsi
	movq	$buf,%rdi
	call	getText
	movq	$buf,%rdi
	call	putText
	movq	$125,%rdi
	call	putInt
	call	outImage
	movq	$endMsg,%rdi
	call	putText
	call	outImage
	popq	%rax
	ret

##################################
inImage:
	movq 	$buf, %rdi
	movq 	$64 , %rsi
	movq 	stdin, %rdx
	call 	fgets
	movq	$0, inbufindex
	ret
	

##################################	
getInt:
	movq 	$buf, %r15
	addq 	inbufindex, %r15
	movq 	$0, %rax
	movq 	$0, %r11

blancCheck:
	cmpb	$' ', (%r15)
	jne 	signPlus
	incq 	%r15
	incq	inbufindex
	jmp 	blancCheck

signPlus:
	cmpb 	$'+', (%r15)
	jne 	signMinus
	incq 	%r15
	incq	inbufindex
	jmp 	Number

signMinus:
	cmpb 	$'-', (%r15)
	jne 	Number
	movq 	$1, %r11
	incq	inbufindex
	incq 	%r15

Number:
	cmpb 	$'0', (%r15)
	jl 	another
	cmpb 	$'9', (%r15)
	jg 	another
	movzbq 	(%r15), %r10
	subq 	$'0', %r10
	imulq	$10, %rax
	addq 	%r10, %rax
	incq 	%r15
	incq	inbufindex
	jmp 	Number

another:
	cmpq 	$1, %r11
	jne 	getIntEnd
	negq 	%rax

getIntEnd: 
	ret


#####################################
putInt:
	pushq	$0
	cmpq 	$0, %rdi
	jl	negNumber
	jmp	putIntL

negNumber:
	negq 	%rdi
	pushq	%rdi
	movq	$'-', %rdi
	call	putChar
	popq	%rdi
	jmp 	putIntL
	
putIntL:
	movq 	%rdi, %rax
	movq 	$10, %r11
	movq 	$0, %rdx
	divq	%r11
	addq	$48, %rdx
	pushq	%rdx
	movq 	%rax, %rdi 
	cmpq 	$0, %rax
	jne	putIntL

putIntL2:
	movq	$outbuf, %r13
	addq 	outbufindex, %r13
	popq 	%r12
	cmpq	$0, %r12
	je 	putIntEnd
	addq	%r12, (%r13)
	incq	outbufindex
	incq	%rdi
	jmp 	putIntL2
	
putIntEnd:
	xorq 	%rdi, %rdi 
	xorq 	%rax, %rax
	xorq 	%rdx, %rdx
	ret


###################################
putText:
	xorq	%r11,%r11
	movq	$outbuf, %r11
	addq	outbufindex, %r11
	cmpb	$0, (%rdi)
	je	putTextend	
	movb	(%rdi), %r10b
	movq 	%r10 , (%r11)
	movq	$0, %r10
	incq	outbufindex
	incq	%rdi
	cmpq	$64, outbufindex
	jge	outImage
	jmp	putText
	
putTextend:	
	ret	


################################
getText:
	movq	%rdi, %r8
	movq	$0, %rax
	jmp	getTextL
	
getTextL:
	movq 	$buf, %r15
	addq	inbufindex, %r15
	cmpq 	%rax, %rsi
	jle	getTextEnd
	cmpb 	$0, (%r15)
	je	getTextEnd
	cmpq	$64, inbufindex
	je 	getTextEnd
	movb	(%r15), %r11b
	movb	%r11b, (%r8)
	incq	%r15
	incq	%r8
	incq	%rax
	incq	inbufindex
	jmp 	getTextL
getTextEnd: 
	movq 	$0, (%r8)
	ret
##############################
outImage:
	movq	$0, outbufindex
	movq	$outbuf, %rdi 
	call	puts
	movq 	$0, outbuf
	ret	
	
	
##################################
getChar:
	movq	$buf, %r10
	addq 	inbufindex, %r10
	movb 	(%r10), %r11b
	movq 	%r11, %rax 
	incq 	inbufindex
	ret
###################################
putChar:
	movq 	$outbuf, %r15
	addq 	outbufindex, %r15
	movq 	%rdi, (%r15)	
	incq	outbufindex
	cmpq 	$64, outbufindex
	jg	outImage
	ret
###############################
###############################
getOutPos:

	xorq 	%rax, %rax	
	addq	outbufindex, %rax
	ret
	

##############################
setOutPos:
	cmpq 	$0, %rdi
	jl	case1
	cmpq 	$64, %rdi
	jge	case2
	movq 	%rdi, outbufindex
	ret
case1:
	movq 	$0, outbufindex
	ret
case2:
	movq 	$64, outbufindex

#################################
getInPos:
	xorq 	%rax, %rax
	addq	inbufindex, %rax
	ret
################################
setInPos:
	cmpq 	$0, %rdi
	jle	case1InPos
	cmpq 	$64, %rdi
	jge	case2InPos
	movq 	%rdi, inbufindex
	ret
case1InPos:
	movq 	$0, inbufindex
	ret
case2InPos:
	movq 	$64, inbufindex
	ret

################################

