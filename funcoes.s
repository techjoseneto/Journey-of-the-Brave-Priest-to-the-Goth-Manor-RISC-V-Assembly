# =================================================================
# funcoes.s - Todas as subrotinas do jogo reunidas
# =================================================================
.text

# =================================================================
# SISTEMA DE TECLADO E ENTRADA (JOGADOR)
# =================================================================
WAIT_SPACE:	li t1, 0xFF200000         # Carrega o endereço de controle do SEU teclado

WAIT_SPACE_LOOP:
	        lw t0, 0(t1)              # Lê o bit de controle
	        andi t0, t0, 0x0001       # Mascara o bit menos significativo
	        beq t0, zero, WAIT_SPACE_LOOP # Se não há tecla, fica em loop esperando (trava a tela)
	        
	        lw t2, 4(t1)              # Lê o valor da tecla pressionada
	        li t0, 32                 # Código ASCII da barra de Espaço
	        bne t2, t0, WAIT_SPACE_LOOP # Se pressionou outra tecla, ignora e continua esperando
	        
	        ret                       # Se for Espaço, avança!
	    	ret

KEY2:		li t1,0xFF200000		# carrega o endereco de controle do KDMMIO
		lw t0,0(t1)			# Le bit de Controle Teclado
		andi t0,t0,0x0001		# mascara o bit menos significativo
		beq t0,zero,FIM_KEY		# Se nao ha tecla pressionada entao vai para FIM_KEY
		lw t2,4(t1) 			# le o valor da tecla tecla
		
		li t0,'w'
		beq t2,t0,CHAR_CIMA		# se 'w', sobe
		
		li t0,'a'
		beq t2,t0,CHAR_ESQ		# se 'a', esquerda
		
		li t0,'s'
		beq t2,t0,CHAR_BAIXO		# se 's', desce
		
		li t0,'d'
		beq t2,t0,CHAR_DIR		# se 'd', direita
		
		li t0, 'l'			#se 'l', atira
		beq t2, t0, ATIRA
	
FIM_KEY:	ret				# retorna para o main

ATIRA:		
		la t0, BULLET_ACTIVE
		lw t1, 0(t0)
		bne t1, zero, FIM_KEY		# Se já tem um tiro na tela, não faz nada (impede metralhadora)
		
		# Ativa o tiro!
		li t1, 1
		sw t1, 0(t0)			# BULLET_ACTIVE = 1
		
		# Copia a direção atual do personagem para o tiro
		la t0, CHAR_LOOK_DIR
		lw t1, 0(t0)
		la t2, BULLET_DIR
		sw t1, 0(t2)			# BULLET_DIR = CHAR_DIR
		
		# Faz o tiro nascer exatamente onde o personagem esta
		la t0, CHAR_POS
		lw t1, 0(t0)			# Carrega X e Y do player juntos
		la t2, BULLET_POS
		sw t1, 0(t2)			# Define a posicaoo inicial do tiro
		
		j FIM_KEY

# =================================================================
# MOVIMENTAÇÃO E COLISÃO DO JOGADOR
# =================================================================
CHAR_ESQ:	la t0,CHAR_POS			
		lh t1,0(t0)			
		lh t2,2(t0)			
		addi t1,t1,-16			
		
		srli t3,t2,4			# Y / 16
		li t4,20
		mul t3,t3,t4			
		srli t4,t1,4			# Proximo X / 16
		add t3,t3,t4			
		
		la t4, CURRENT_MAP_MATRIX		
		lw t4, 0(t4)			# Le dinamicamente a matriz da fase ativa
		add t4, t4, t3			
		lbu t5, 0(t4)			# t5 = Bloco atual
		
		beq t5, zero, FIM_MOVE_ESQ	
		
		la t1,OLD_CHAR_POS		
		lw t2,0(t0)			
		sw t2,0(t1)			
		
		lh t1,0(t0)			
		addi t1,t1,-16			
		sh t1,0(t0)
		
		li t1, 3
		la t2, CHAR_LOOK_DIR
		sw t1, 0(t2)			
FIM_MOVE_ESQ:	ret

CHAR_DIR:	la t0,CHAR_POS			
		lh t1,0(t0)			
		lh t2,2(t0)			
		addi t1,t1,16			
		
		srli t3,t2,4			
		li t4,20
		mul t3,t3,t4			
		srli t4,t1,4			
		add t3,t3,t4			
		
		la t4, CURRENT_MAP_MATRIX		
		lw t4, 0(t4)			# Le dinamicamente a matriz da fase ativa
		add t4, t4, t3			
		lbu t5, 0(t4)			# t5 = Bloco atual
		
		beq t5, zero, FIM_MOVE_DIR		
		
		la t1,OLD_CHAR_POS		
		lw t2,0(t0)			
		sw t2,0(t1)			
		
		lh t1,0(t0)			
		addi t1,t1,16			
		sh t1,0(t0)
		
		li t1, 4
		la t2, CHAR_LOOK_DIR
		sw t1, 0(t2)			
FIM_MOVE_DIR:	ret

CHAR_CIMA:	la t0,CHAR_POS			
		lh t1,0(t0)			
		lh t2,2(t0)			
		addi t2,t2,-16			
		
		srli t3,t2,4			
		li t4,20
		mul t3,t3,t4			
		srli t4,t1,4			
		add t3,t3,t4			
		
		la t4, CURRENT_MAP_MATRIX		
		lw t4, 0(t4)			# Le dinamicamente a matriz da fase ativa
		add t4, t4, t3			
		lbu t5, 0(t4)			# t5 = Bloco atual
		
		beq t5, zero, FIM_MOVE_CIMA		
		
		la t1,OLD_CHAR_POS		
		lw t2,0(t0)			
		sw t2,0(t1)			
		
		lh t2,2(t0)			
		addi t2,t2,-16			
		sh t2,2(t0)
		
		li t1, 1
		la t2, CHAR_LOOK_DIR
		sw t1, 0(t2)			
FIM_MOVE_CIMA:	ret

CHAR_BAIXO:	la t0,CHAR_POS			
		lh t1,0(t0)			
		lh t2,2(t0)			
		addi t2,t2,16			
		
		srli t3,t2,4			
		li t4,20
		mul t3,t3,t4			
		srli t4,t1,4			
		add t3,t3,t4			
		
		la t4, CURRENT_MAP_MATRIX		
		lw t4, 0(t4)			# Le dinamicamente a matriz da fase ativa
		add t4, t4, t3			
		lbu t5, 0(t4)			# t5 = Bloco atual
		
		beq t5, zero, FIM_MOVE_BAIXO	
		
		la t1,OLD_CHAR_POS		
		lw t2,0(t0)			
		sw t2,0(t1)			
		
		lh t2,2(t0)			
		addi t2,t2,16			
		sh t2,2(t0)
		
		li t1, 2
		la t2, CHAR_LOOK_DIR
		sw t1, 0(t2)			
FIM_MOVE_BAIXO:	ret

# =================================================================
# MOVIMENTAÇÃO DO INIMIGO
# =================================================================
# =================================================================
# ATUALIZA_INIMIGO)
# =================================================================
ATUALIZA_INIMIGO:
		# 1. Só processa se o inimigo estiver puramente ativo/vivo (== 1)
		lw t1, 0(a2)
		li t2, 1
		bne t1, t2, FIM_ATUALIZA_INIMIGO
		
		# 2. CONTROLE DE VELOCIDADE INDIVIDUAL
		# Carrega, incrementa e salva o contador específico passado em a4
		lw t1, 0(a4)
		addi t1, t1, 1
		sw t1, 0(a4)			

		la t2, ENEMY_SPEED
		lw t2, 0(t2)
		blt t1, t2, EXECUTA_DESENHO_ENEMY # Se não deu o tempo, pula movimento e só desenha
		
		# Se chegou aqui, deu o tempo de andar! Zera o contador individual deste inimigo
		sw zero, 0(a4)			

CONTINUA_IA:
		# Salva os argumentos na pilha antes do processamento
		# Incluímos o a4 na pilha para garantir que ele não se perca se houver subchamadas
		addi sp, sp, -24
		sw ra, 0(sp)
		sw a0, 4(sp)
		sw a1, 8(sp)
		sw a2, 12(sp)
		sw a3, 16(sp)
		sw a4, 20(sp)

		lh t3, 0(a0)			# t3 = Inimigo X
		lh t4, 2(a0)			# t4 = Inimigo Y
		
		lw t2, 0(a0)			
		sw t2, 0(a1)			
		
		la t1, CHAR_POS
		lh t5, 0(t1)			# t5 = Player X
		lh t6, 2(t1)			# t6 = Player Y
		
		beq t3, t5, IA_Y		
		blt t3, t5, IA_DIR		
IA_ESQ:		addi t3, t3, -16
		j CHK_COLISAO_ENEMY
IA_DIR:		addi t3, t3, 16
		j CHK_COLISAO_ENEMY

IA_Y:		beq t4, t6, RESTAURA_PILHA_ENEMY	
		blt t4, t6, IA_BAIXO
IA_CIMA:	addi t4, t4, -16
		j CHK_COLISAO_ENEMY
IA_BAIXO:	addi t4, t4, 16

CHK_COLISAO_ENEMY:
		srli t1, t4, 4			
		li t2, 20
		mul t1, t1, t2			
		srli t2, t3, 4			
		add t1, t1, t2			
		
		la t2, CURRENT_MAP_MATRIX
		lw t2, 0(t2)
		add t2, t2, t1
		lbu t1, 0(t2)			
		
		beq t1, zero, RESTAURA_PILHA_ENEMY

SUCESSO_MOVE_ENEMY:
		lw a0, 4(sp)
		sh t3, 0(a0)
		sh t4, 2(a0)

RESTAURA_PILHA_ENEMY:
		lw ra, 0(sp)
		lw a0, 4(sp)
		lw a1, 8(sp)
		lw a2, 12(sp)
		lw a3, 16(sp)
		lw a4, 20(sp)
		addi sp, sp, 24

# -----------------------------------------------------------------
# RENDERIZAÇÃO ESTÁVEL DO SPRITE (Mantida igual)
# -----------------------------------------------------------------
EXECUTA_DESENHO_ENEMY:
		addi sp, sp, -4
		sw ra, 0(sp)
		
		la t1, ENEMY_A_POS
		beq a0, t1, USA_SPRITE_A

USA_SPRITE_B:
		mv t0, a0 
		la a0, inimigoB	
		j PRONTO_PARA_DESENHAR

USA_SPRITE_A:
		mv t0, a0
		la a0, inimigoA			

PRONTO_PARA_DESENHAR:
		lh a1, 0(t0)			
		lh a2, 2(t0)			
		call PRINT	
		
		lw ra, 0(sp)
		addi sp, sp, 4

FIM_ATUALIZA_INIMIGO:
		ret

# =================================================================
# LIMPEZA DE RASTRO (PLAYER E INIMIGO)
# =================================================================
LIMPA_RASTRO_PLAYER:
		# Verifica se o player acabou de renascer (necessita de limpeza dupla da morte)
		la t0, PLAYER_RESPAWN_COUNT
		lw t1, 0(t0)
		blez t1, LIMPA_RASTRO_NORMAL_PLAYER	# Se for 0, segue o rastro normal de movimento
		
		# --- CASO ESPECIAL: LIMPANDO O FANTASMA DA MORTE ---
		addi t1, t1, -1
		sw t1, 0(t0)				# Decrementa o contador (2 -> 1 -> 0)
		
		la t0, PLAYER_DEATH_POS			# Forca a limpeza na coordenada da morte
		lh a1, 0(t0)
		lh a2, 2(t0)
		j EXECUTA_LIMPEZA_PLAYER

LIMPA_RASTRO_NORMAL_PLAYER:
		# Limpeza padrao usada durante o jogo caminhando normal
		la t0, OLD_CHAR_POS		
		lh a1, 0(t0)			
		lh a2, 2(t0)			

EXECUTA_LIMPEZA_PLAYER:
		addi sp, sp, -4
		sw ra, 0(sp)
		call ENCONTRA_TEXTURA			# Redesenha o chao do mapa
		lw ra, 0(sp)
		addi sp, sp, 4
		ret		

# =================================================================
# LIMPA RASTRO INIMIGO
# Entradas:
#   a0 = Endereço de ENEMY_X_OLD_POS (ex: la a0, ENEMY_A_OLD_POS)
#   a1 = Endereço de ENEMY_X_ACTIVE  (ex: la a1, ENEMY_A_ACTIVE)
# =================================================================
LIMPA_RASTRO_INIMIGO:
		# Verifica se o inimigo (globalmente) acabou de atacar o player
		la t0, ENEMY_RESPAWN_COUNT
		lw t1, 0(t0)
		blez t1, LOGICA_PADRAO_ENEMY	# Se for 0, segue o jogo normal
		
		# CASO ESPECIAL DE ATAQUE
		addi t1, t1, -1
		sw t1, 0(t0)				
		
		addi sp, sp, -4
		sw ra, 0(sp)		
		
		la t0, ENEMY_DEATH_POS			
		lh a1, 0(t0)
		lh a2, 2(t0)
		call ENCONTRA_TEXTURA			
		
		la t0, ENEMY_PENULTIMA_POS
		lh a1, 0(t0)
		lh a2, 2(t0)
		call ENCONTRA_TEXTURA			
		
		lw ra, 0(sp)			
		addi sp, sp, 4			
		ret					

LOGICA_PADRAO_ENEMY:
		# Lê o estado de atividade DESTE inimigo específico (usando a1)
		lw t1, 0(a1)
		beq t1, zero, FIM_RASTRO_ENEMY	# Se for 0 (morto definitivo), não limpa nada
		
		# Salva na pilha os registradores de argumento que vamos precisar depois
		addi sp, sp, -12
		sw ra, 0(sp)
		sw a1, 4(sp)        # Guarda o endereço do ACTIVE
		sw t1, 8(sp)        # Guarda o valor atual do ACTIVE

		# Carrega a coordenada antiga DESTE inimigo específico (usando a0)
		lh a1, 0(a0)			
		lh a2, 2(a0)			

		call ENCONTRA_TEXTURA		# Redesenha o chão na posição antiga
		
		# Recupera os dados da pilha
		lw ra, 0(sp)
		lw a1, 4(sp)        # Endereço do ACTIVE deste inimigo
		lw t1, 8(sp)        # Valor do ACTIVE deste inimigo
		addi sp, sp, 12

		# --- MÁQUINA DE ESTADOS DO RASTRO DE MORTE DESTE INIMIGO ---
		li t2, 2
		beq t1, t2, ENEMY_VA_PARA_3	
		li t2, 3
		beq t1, t2, ENEMY_VA_PARA_0	
		
		j FIM_RASTRO_ENEMY

ENEMY_VA_PARA_3:
		li t3, 3
		sw t3, 0(a1)			# Atualiza o ACTIVE deste inimigo para 3
		j FIM_RASTRO_ENEMY

ENEMY_VA_PARA_0:
		sw zero, 0(a1)			# Desativa este inimigo de vez (0) após limpar todos os frames

FIM_RASTRO_ENEMY:
		ret
		
		
# =================================================================
# FUNCAO QUE DEFINE A TEXTURA A SUBSTITUIR APOS O PLAYER SE MOVER
# =================================================================	
ENCONTRA_TEXTURA:
		srli t3,a2,4			
		li t4,20
		mul t3,t3,t4			
		srli t4,a1,4			
		add t3,t3,t4			
		
		la t4, CURRENT_MAP_MATRIX
		lw t4, 0(t4)
		add t4, t4, t3
		lbu t5, 0(t4)			# t5 = Código do bloco na matriz
		
		# Checa qual fase está ativa para escolher o grupo de texturas
		la t4, CURRENT_LEVEL
		lw t4, 0(t4)
		li t6, 2
		beq t4, t6, TEXTURAS_FASE2
		li t6, 3
		beq t4, t6, TEXTURAS_FASE3
		
TEXTURAS_FASE1:
		# --- CORREÇÃO: Aponta para as rotinas de desenho corretas ---
		li t6, 12
		beq t5, t6, TXT_M1_CAMINHO_ESQ
		li t6, 13
		beq t5, t6, TXT_M1_CAMINHO_DIR
		li t6, 14
		beq t5, t6, TXT_M1_ESCADA_ESQ
		li t6, 15
		beq t5, t6, TXT_M1_ESCADA_DIR

		# Padrão de segurança: caso seja a calçada (11) ou porta (19) 
		# onde não salvamos texturas específicas de rastro ainda
		la a0, MAPA1 # Recarrega do fundo original se for bloco padrão
		j DESENHA_RASTRO

TXT_M1_CAMINHO_ESQ:
		la a0, cenario1_pedra_esquerda    # Sprite metade pedra/metade grama (Esquerda)
		j DESENHA_RASTRO
TXT_M1_CAMINHO_DIR:
		la a0, cenario1_pedra_direita     # Sprite metade pedra/metade grama (Direita)
		j DESENHA_RASTRO
TXT_M1_ESCADA_ESQ:
		la a0, cenario1_escada_esquerda   # Sprite do degrau esquerdo
		j DESENHA_RASTRO
TXT_M1_ESCADA_DIR:
		la a0, cenario1_escada_direita    # Sprite do degrau direito
		j DESENHA_RASTRO
		
TEXTURAS_FASE2:
		# CORREÇÃO: Aponta para as labels de código corretas (TXT_M2_...)
		li t6, 21
		beq t5, t6, TXT_M2_PISO
		
		la a0, cenario2_piso		# Padrão de segurança caso passe em cima de outro valor
		j DESENHA_RASTRO

TXT_M2_PISO:        la a0, cenario2_piso		
                      j DESENHA_RASTRO

TEXTURAS_FASE3:
		la a0, cenario3_piso    
		j DESENHA_RASTRO

DESENHA_RASTRO:
		addi sp, sp, -4
		sw ra, 0(sp)
		
		mv a3,s0			
		xori a3,a3,1			
		call PRINT			

		lw ra, 0(sp)
		addi sp, sp, 4
		ret	

# =================================================================
# MECANICA DO TIRO
# =================================================================

MOVE_BULLET:
		la t0, BULLET_ACTIVE
		lw t1, 0(t0)
		li t2, 1
		bne t1, t2, FIM_MOVE_BULLET	# Só calcula movimento se o tiro estiver ativo (1)
		
		# Salva a posição atual como ANTIGA antes de aplicar a velocidade
		la t0, BULLET_POS
		lw t1, 0(t0)
		la t2, OLD_BULLET_POS
		sw t1, 0(t2)

		lh t3, 0(t0)			# t3 = Projétil X
		lh t4, 2(t0)			# t4 = Projétil Y

		# Identifica a direção do tiro
		la t0, BULLET_DIR
		lw t1, 0(t0)

		li t2, 1
		beq t1, t2, B_CIMA
		li t2, 2
		beq t1, t2, B_BAIXO
		li t2, 3
		beq t1, t2, B_ESQ
		li t2, 4
		beq t1, t2, B_DIR
		j FIM_MOVE_BULLET

B_CIMA:		addi t4, t4, -16
		j CHK_B_COLISAO
B_BAIXO:	addi t4, t4, 16
		j CHK_B_COLISAO
B_ESQ:		addi t3, t3, -16
		j CHK_B_COLISAO
B_DIR:		addi t3, t3, 16

# -----------------------------------------------------------------
#  DETECÇÃO DE IMPACTO DUPLA
# -----------------------------------------------------------------
CHK_B_COLISAO: 					
		# --- TESTA COLISÃO COM INIMIGO A ---
		la t0, ENEMY_A_ACTIVE
		lw t1, 0(t0)
		li t2, 1
		bne t1, t2, CHK_BULLET_INIMIGO_B # Se o A não está ativo jogável, testa o B
		
		la t0, ENEMY_A_POS
		lh t1, 0(t0)			# t1 = Inimigo A X
		lh t2, 2(t0)			# t2 = Inimigo A Y
		
		bne t3, t1, CHK_BULLET_INIMIGO_B # Se X não bateu, testa o B
		bne t4, t2, CHK_BULLET_INIMIGO_B # Se Y não bateu, testa o B
		
		# HOUVE IMPACTO NO INIMIGO A!
		la a0, ENEMY_A_POS
		la a1, ENEMY_A_OLD_POS
		la a2, ENEMY_A_ACTIVE
		la a3, ENEMY_A_LIVES
		j EXECUTA_DANO_INIMIGO

CHK_BULLET_INIMIGO_B:
		# --- TESTA COLISÃO COM INIMIGO B ---
		la t0, ENEMY_B_ACTIVE
		lw t1, 0(t0)
		li t2, 1
		bne t1, t2, CHK_PAREDE_BULLET	# Se o B também não está ativo, pula pro cenário
		
		la t0, ENEMY_B_POS
		lh t1, 0(t0)			# t1 = Inimigo B X
		lh t2, 2(t0)			# t2 = Inimigo B Y
		
		bne t3, t1, CHK_PAREDE_BULLET	
		bne t4, t2, CHK_PAREDE_BULLET	
		
		# HOUVE IMPACTO NO INIMIGO B!
		la a0, ENEMY_B_POS
		la a1, ENEMY_B_OLD_POS
		la a2, ENEMY_B_ACTIVE
		la a3, ENEMY_B_LIVES

EXECUTA_DANO_INIMIGO:
		# Desativa o tiro (joga para animação de explosão 2)
		la t0, BULLET_ACTIVE
		li t1, 2
		sw t1, 0(t0)
		
		# Protege registradores na pilha e processa o Respawn/Morte
		addi sp, sp, -4
		sw ra, 0(sp)
		call RESPAWN_INIMIGO
		lw ra, 0(sp)
		addi sp, sp, 4
		
		j FIM_MOVE_BULLET		# Encerra o frame do tiro

# -----------------------------------------------------------------
#  COLISÃO COM CENÁRIO E PAREDES
# -----------------------------------------------------------------
CHK_PAREDE_BULLET:
		blt t3, zero, B_MORRE
		li t1, 320
		bge t3, t1, B_MORRE
		blt t4, zero, B_MORRE
		li t1, 240
		bge t4, t1, B_MORRE

		srli t1, t4, 4			
		li t2, 20
		mul t1, t1, t2			
		srli t2, t3, 4			
		add t1, t1, t2			
		
		la t2, CURRENT_MAP_MATRIX
		lw t2, 0(t2)
		add t2, t2, t1
		lbu t1, 0(t2)			
		
		beq t1, zero, B_MORRE
		li t6, 19
		beq t1, t6, B_MORRE

SUCESSO_BULLET:
		la t0, BULLET_POS
		sh t3, 0(t0)
		sh t4, 2(t0)
		j FIM_MOVE_BULLET

B_MORRE:
		la t0, BULLET_ACTIVE
		li t1, 2
		sw t1, 0(t0)

FIM_MOVE_BULLET:
		ret
		
		
# =================================================================
# SUB-ROTINA: RESPAWN_INIMIGO
# Entradas passadas pelo impacto do tiro:
#   a0 = Endereço de ENEMY_X_POS
#   a1 = Endereço de ENEMY_X_OLD_POS
#   a2 = Endereço de ENEMY_X_ACTIVE
#   a3 = Endereço de ENEMY_X_LIVES
# =================================================================
RESPAWN_INIMIGO:
		# 1. Soma +1 no contador de baixas gerais da Fase 2
		la t0, TOTAL_DEFEATED
		lw t1, 0(t0)
		addi t1, t1, 1
		sw t1, 0(t0)

		# 2. Reduz 1 vida deste inimigo específico
		lw t1, 0(a3)			# t1 = vidas restantes
		addi t1, t1, -1
		sw t1, 0(a3)			# Atualiza na memória
		
		# Força o rastro antigo a ser onde ele acabou de ser baleado (para limpar frame)
		lw t2, 0(a0)
		sw t2, 0(a1)

		# Se as vidas DESTE inimigo zeraram, ele morre em definitivo
		bnez t1, FAZ_TELETRANSPORTE_RESPAWN
		
		# --- CASO: MORTE DEFINITIVA ---
		li t2, 2
		sw t2, 0(a2)			# Joga ACTIVE para estado 2 (Inicia sequência de sumiço)
		ret

		# --- CASO: RENASCIMENTO EM NOVO PONTO ---
FAZ_TELETRANSPORTE_RESPAWN:
		# Descobre qual é o próximo ponto de spawn da lista (0, 1, 2 ou 3)
		la t0, SPAWN_INDEX
		lw t1, 0(t0)			# t1 = índice atual (0 a 3)
		
		# Calcula o deslocamento na tabela SPAWN_POINTS (Cada ponto tem 4 bytes: .half X, Y)
		slli t2, t1, 2			# t2 = índice * 4
		la t3, SPAWN_POINTS
		add t3, t3, t2			# t3 = Endereço exato do par X,Y escolhido
		
		# Carrega as novas coordenadas de spawn
		lh t4, 0(t3)			# Novo X
		lh t5, 2(t3)			# Novo Y
		
		# Aplica o teletransporte instantâneo no inimigo!
		sh t4, 0(a0)
		sh t5, 2(a0)
		
		# Atualiza o SPAWN_INDEX para que o PRÓXIMO inimigo que morrer nasça em outro lugar
		addi t1, t1, 1			# Próximo índice
		li t2, 4
		blt t1, t2, SALVA_INDEX
		li t1, 0			# Se passou de 3, volta para o ponto 0 (Loop circular)
SALVA_INDEX:
		sw t1, 0(t0)
		ret	

# --- DESENHO DO TIRO ---
DESENHA_BULLET:
		la t0, BULLET_ACTIVE
		lw t1, 0(t0)
		li t2, 1
		bne t1, t2, FIM_DRAW_BULLET	# Só desenha se estiver puramente ativo (1)

		la t0, BULLET_POS
		la a0, cenario2_branco			# SUA TEXTURA: Quadrado branco temporário
		lh a1, 0(t0)
		lh a2, 2(t0)
		mv a3, s0			# Passa o frame atual
		
		addi sp, sp, -4
		sw ra, 0(sp)
		call PRINT			
		lw ra, 0(sp)
		addi sp, sp, 4

FIM_DRAW_BULLET:
		ret

# --- LIMPEZA DE RASTRO DO TIRO (INTEGRADO AO SISTEMA COMPARTILHADO) ---
LIMPA_RASTRO_BULLET:
		la t0, BULLET_ACTIVE
		lw t1, 0(t0)
		beq t1, zero, FIM_RASTRO_BULLET	# Se for 0 (Totalmente inativo), não faz nada
		
		# Guardamos o estado na pilha para decidir o pós-limpeza
		addi sp, sp, -4
		sw t1, 0(sp)

		# Prepara os parâmetros usando a posição antiga do tiro
		la t0, OLD_BULLET_POS
		lh a1, 0(t0)
		lh a2, 2(t0)
		
		addi sp, sp, -4
		sw ra, 0(sp)
		call ENCONTRA_TEXTURA		# Executa o mapeador do cenário compartilhado
		lw ra, 0(sp)
		addi sp, sp, 4

		lw t1, 0(sp)
		addi sp, sp, 4

		# --- SISTEMA DE LIMPEZA DUPLA (DOUBLE BUFFERING) ---
		li t2, 2
		beq t1, t2, BULLET_VA_PARA_3
		li t2, 3
		beq t1, t2, BULLET_VA_PARA_0
		
		j FIM_RASTRO_BULLET

BULLET_VA_PARA_3:
		la t0, BULLET_ACTIVE
		li t1, 3
		sw t1, 0(t0)			# Configura para limpar o segundo frame do tiro
		j FIM_RASTRO_BULLET

BULLET_VA_PARA_0:
		la t0, BULLET_ACTIVE
		sw zero, 0(t0)			# Tiro completamente limpo e pronto para novo disparo

FIM_RASTRO_BULLET:
		ret

# =================================================================
# RENDERIZADOR DE SPRITES (PRINT)
# =================================================================
PRINT:		li t0,0xFF0			
		add t0,t0,a3			
		slli t0,t0,20			
		add t0,t0,a1			
		
		li t1,320			
		mul t1,t1,a2			
		add t0,t0,t1			
		addi t1,a0,8			
		
		mv t2,zero			
		mv t3,zero			
		lw t4,0(a0)			
		lw t5,4(a0)			
		
PRINT_LINHA:	lw t6,0(t1)			
		sw t6,0(t0)			
		
		addi t0,t0,4			
		addi t1,t1,4			
		addi t3,t3,4			
		blt t3,t4,PRINT_LINHA		

		addi t0,t0,320			
		sub t0,t0,t4			
		
		mv t3,zero			
		addi t2,t2,1			
		bgt t5,t2,PRINT_LINHA		
		
		ret
		
# =================================================================
# SISTEMA DE DANO E VIDAS (PLAYER VS INIMIGO DUPLO)
# =================================================================
VERIFICA_DANO_PLAYER:
		# Coordenadas atuais do player (comum para os testes)
		la t0, CHAR_POS
		lh t1, 0(t0)			
		lh t2, 2(t0)			

		# --- TESTA COLISÃO COM INIMIGO A ---
		la t3, ENEMY_A_ACTIVE
		lw t4, 0(t3)
		li t5, 1
		bne t4, t5, TESTA_INIMIGO_B	# Se o A não está ativo, pula para testar o B
		
		la t3, ENEMY_A_POS
		lh t4, 0(t3)			
		lh t5, 2(t3)			
		
		bne t1, t4, TESTA_INIMIGO_B	# Se X não bateu, testa o B
		bne t2, t5, TESTA_INIMIGO_B	# Se Y não bateu, testa o B
		
		# SE CHEGOU AQUI, O INIMIGO A ALCANÇOU O PLAYER!
		la a0, ENEMY_A_POS		# Passa dados do A por argumento
		la a1, ENEMY_A_OLD_POS
		li a2, 288			# X de reset do A (Ponto 0)
		li a3, 128			# Y de reset do A
		j APLICA_DANO_LOGICA
		
		# --- ADICIONAR NO FINAL DE VERIFICA_DANO_PLAYER ---
		la t0, BOSS_ACTIVE
		lw t1, 0(t0)
		li t2, 1
		bne t1, t2, FIM_DANO_BOSS # Se o boss não estiver ativo, pula
		
		la t0, CHAR_POS
		lh t1, 0(t0)			# Player X
		lh t2, 2(t0)			# Player Y
		
		la t3, BOSS_POS
		lh t4, 0(t3)			# Boss X
		lh t5, 2(t3)			# Boss Y
		
		bne t1, t4, FIM_DANO_BOSS
		bne t2, t5, FIM_DANO_BOSS
		
		# Se as coordenadas forem iguais, o Boss te acertou!
		la a0, BOSS_POS
		la a1, BOSS_OLD_POS
		li a2, 144
		li a3, 48
		j APLICA_DANO_LOGICA	# Tira vida e te teleporta pro início da fase
		
FIM_DANO_BOSS:

TESTA_INIMIGO_B:
		# --- TESTA COLISÃO COM INIMIGO B ---
		la t3, ENEMY_B_ACTIVE
		lw t4, 0(t3)
		li t5, 1
		bne t4, t5, FIM_VERIFICA_DANO	# Se o B também não está ativo, encerra
		
		la t3, ENEMY_B_POS
		lh t4, 0(t3)			
		lh t5, 2(t3)			
		
		bne t1, t4, FIM_VERIFICA_DANO	
		bne t2, t5, FIM_VERIFICA_DANO	
		
		# SE CHEGOU AQUI, O INIMIGO B ALCANÇOU O PLAYER!
		la a0, ENEMY_B_POS		# Passa dados do B por argumento
		la a1, ENEMY_B_OLD_POS
		li a2, 128			# X de reset do B (Ponto 1)
		li a3, 112			# Y de reset do B

# -----------------------------------------------------------------
# ROTINA CORE DE PROCESAMENTO DE DANO (Acionada por qualquer inimigo)
# -----------------------------------------------------------------
APLICA_DANO_LOGICA:
		# Subtrai uma vida do jogador
		la t0, PLAYER_LIVES
		lw t1, 0(t0)
		addi t1, t1, -1
		sw t1, 0(t0)
		
		# Se as vidas ainda forem maiores que zero, continua o jogo (reposiciona)
		bgtz t1, CONTINUA_VIVO   # <--- CORREÇÃO: Pula o Game Over e vai para o reset do round
		
		# --- SE CHEGOU AQUI, É GAME OVER (0 VIDAS) ---
		addi sp, sp, -4
		sw ra, 0(sp)
		li a0, 60                # Espera ~60 frames com o player morto na tela
		call ESPERA_FRAMES
		lw ra, 0(sp)
		addi sp, sp, 4
		
		j TELA_GAME_OVER         # Vai para o fim do jogo definitivo

CONTINUA_VIVO:                   # <--- CORREÇÃO: Label adicionada aqui!
		# Configura limpeza do fantasma da morte do Player
		la t0, CHAR_POS
		lw t1, 0(t0)			
		la t2, PLAYER_DEATH_POS
		sw t1, 0(t2)			
		
		la t0, PLAYER_RESPAWN_COUNT
		li t1, 2
		sw t1, 0(t0)			

		# Configura limpeza do fantasma do inimigo que atacou (usando a0 e a1)
		lw t1, 0(a0)			
		la t2, ENEMY_DEATH_POS
		sw t1, 0(t2)			

		lw t1, 0(a1)			
		la t2, ENEMY_PENULTIMA_POS
		sw t1, 0(t2)			

		la t0, ENEMY_RESPAWN_COUNT
		li t1, 2
		sw t1, 0(t0)			

		# --- REPOSICIONA OS ATORES ---
		# Player volta para a base inferior (160, 208)
		li t1, 160
		li t2, 208
		la t0, CHAR_POS
		sh t1, 0(t0)
		sh t2, 2(t0)
		la t0, OLD_CHAR_POS
		sh t1, 0(t0)
		sh t2, 2(t0)
		
		# Salva X (a2) e Y (a3) do inimigo corretamente sem misturar os dados
		sh a2, 0(a0)	# Define o novo X na posição atual
		sh a3, 2(a0)	# Define o novo Y na posição atual
		sh a2, 0(a1)	# Define o novo X na posição antiga (rastro)
		sh a3, 2(a1)	# Define o novo Y na posição antiga (rastro)

FIM_VERIFICA_DANO:
		ret
		
# --- TELA DE GAME OVER E REINÍCIO ---
TELA_GAME_OVER:
        	# 1. Desenha a imagem/texto de derrota nos dois buffers
	        la a0, derrotatxt        # Label do include da sua tela de game over
	        li a1, 0                 # X = 0
	        li a2, 0                 # Y = 0
	        li a3, 0                 # Buffer 0
	        call PRINT
	        li a3, 1                 # Buffer 1
	        call PRINT
	        # 2. Trava a tela esperando o jogador apertar Espaço
	        call WAIT_SPACE
	        # =========================================================
	        # REINICIALIZAÇÃO DO JOGO (RESET DE VARIÁVEIS)
	        # =========================================================
	        # Reseta as vidas do player para 3
	        la t0, PLAYER_LIVES
	        li t1, 3
	        sw t1, 0(t0)
	        # Reseta o nível atual para 1
	        la t0, CURRENT_LEVEL
	        li t1, 1
	        sw t1, 0(t0)
	        # Reseta os contadores de respawn/fantasma para evitar lixo visual
	        la t0, PLAYER_RESPAWN_COUNT
	        sw zero, 0(t0)
	        la t0, ENEMY_RESPAWN_COUNT
	        sw zero, 0(t0)
	        # Reseta os inimigos para inativos (recomeçar da fase 1 limpo)
	        la t0, ENEMY_A_ACTIVE
	        sw zero, 0(t0)
	        la t0, ENEMY_B_ACTIVE
	        sw zero, 0(t0)
	        la t0, BULLET_ACTIVE
	        sw zero, 0(t0)
	        # Reseta a posição do Personagem para o local inicial (160, 208)
	        li t1, 144
	        li t2, 144
	        la t0, CHAR_POS
	        sh t1, 0(t0)
	        sh t2, 2(t0)
	        la t0, OLD_CHAR_POS
	        sh t1, 0(t0)
	        sh t2, 2(t0)
	        # 3. Força o redesenho do mapa inicial para limpar a imagem de derrota
	        la t0, MATRIZ_MAPA1
	        la t1, CURRENT_MAP_MATRIX
	        sw t0, 0(t1)
	        la t0, MAPA1
	        la t1, CURRENT_MAP_BG
	        sw t0, 0(t1)
	        lw a0, 0(t1)             # Recarrega o MAPA1
	        li a1, 0                
	        li a2, 0                
	        li a3, 0                
	        call PRINT               # Limpa Buffer 0
	        li a3, 1                
	        call PRINT               # Limpa Buffer 1
	        li s0, 0                 # Reinicia o sincronizador de frame (Double Buffering)
	        # 4. Salta de volta para o início do jogo (Game Loop)
	        j GAME_LOOP
	        
TELA_VITORIA:
		# 1. Desenha a imagem/texto de derrota nos dois buffers
	        la a0, vitoriatxt        # Label do include da sua tela de game over
	        li a1, 0                 # X = 0
	        li a2, 0                 # Y = 0
	        li a3, 0                 # Buffer 0
	        call PRINT
	        li a3, 1                 # Buffer 1
	        call PRINT
	        j FIM
		
# =================================================================
# VERIFICA SE O TIRO DO JOGADOR ACERTOU O CHEFÃO
# =================================================================
VERIFICA_DANO_BOSS:
		# Só checa se o Boss estiver totalmente ativo (1) e tiro ativo (1)
		la t0, BOSS_ACTIVE
		lw t1, 0(t0)
		li t2, 1
		bne t1, t2, FIM_DANO_DO_CHEFAO

		la t0, BULLET_ACTIVE    
		lw t1, 0(t0)
		li t2, 1
		bne t1, t2, FIM_DANO_DO_CHEFAO

		# Carrega a posição do Tiro do Player
		la t0, BULLET_POS       
		lh t1, 0(t0)            # Tiro X
		lh t2, 2(t0)            # Tiro Y

		# Carrega a posição do Boss
		la t3, BOSS_POS
		lh t4, 0(t3)            # Boss X
		lh t5, 2(t3)            # Boss Y

		# Compara as coordenadas X e Y
		bne t1, t4, FIM_DANO_DO_CHEFAO
		bne t2, t5, FIM_DANO_DO_CHEFAO

		# --- IMPACTO DETECTADO! ---
		
		# 1. Desativa o tiro do jogador (vai para o estado de sumiço)
		la t0, BULLET_ACTIVE
		li t1, 2                
		sw t1, 0(t0)

		# 2. Subtrai vida do Boss
		la t0, BOSS_LIVES
		lw t1, 0(t0)
		addi t1, t1, -1         
		sw t1, 0(t0)

		# 3. Verifica se o Boss morreu
		bgtz t1, FIM_DANO_DO_CHEFAO  

		# --- O BOSS MORREU! ---
		# Em vez de travar tudo com ESPERA_FRAMES, ativamos a sequência de morte fluida
		la t0, BOSS_ACTIVE
		li t1, 2                # Estado 2: Limpar o frame atual
		sw t1, 0(t0)

FIM_DANO_DO_CHEFAO:
		ret
		
		VERIFICA_DEATH_TIMER:
		la t0, BOSS_ACTIVE
		lw t1, 0(t0)
		
		# Se o boss está vivo (1) ou totalmente limpo (0), não faz nada
		beq t1, zero, FIM_DEATH_TIMER
		li t2, 1
		beq t1, t2, FIM_DEATH_TIMER
		
		# Se está no estado 2, muda para o estado 3 (para limpar no frame inverso)
		li t2, 2
		bne t1, t2, BOSS_EM_ESPERA
		
		la t0, BOSS_ACTIVE
		li t1, 3
		sw t1, 0(t0)
		ret

BOSS_EM_ESPERA:
		# Se chegou aqui, BOSS_ACTIVE == 3 (Os dois frames de rastro já foram limpos)
		# Incrementa o temporizador que criamos na memória
		la t0, BOSS_DEATH_TIMER
		lw t1, 0(t0)
		addi t1, t1, 1
		sw t1, 0(t0)
		
		li t2, 60               # ~60 frames de espera (aprox. 1 segundo)
		blt t1, t2, FIM_DEATH_TIMER
		
		# O tempo acabou! Vai para a tela de Vitória
		j TELA_VITORIA

FIM_DEATH_TIMER:
		ret

		
		
# =================================================================
# MUDANCA DE FASE
# =================================================================
		
# =================================================================
# MUDANÇA DE FASE E TRANSIÇÃO DE CENÁRIO (ATUALIZADA MAPA 3)
# =================================================================
VERIFICA_MUDANCA_FASE:
		la t0, CURRENT_LEVEL
		lw t1, 0(t0)
		
		li t2, 1
		beq t1, t2, CHECKA_FASE_1	# Se está na Fase 1, faz a lógica antiga
		li t2, 2
		beq t1, t2, CHECKA_FASE_2	# Se está na Fase 2, faz a nova lógica do Boss
		j FIM_MUDANCA			# Se já for Fase 3, não faz nada

# -----------------------------------------------------------------
# LOGICA DA PORTA DO MAPA 1 -> MAPA 2 (Mantida igual)
# -----------------------------------------------------------------
CHECKA_FASE_1:
		la t0, CHAR_POS
		lh t1, 0(t0)			
		lh t2, 2(t0)			
		srli t3, t2, 4			
		li t4, 20				
		mul t3, t3, t4			
		srli t4, t1, 4			
		add t3, t3, t4			
		la t4, CURRENT_MAP_MATRIX
		lw t4, 0(t4)			
		add t4, t4, t3			
		lbu t5, 0(t4)			
		
		li t6, 19			
		bne t5, t6, FIM_MUDANCA	
		
		# GATILHO: ENTROU NO MAPA 2
		la t0, CURRENT_LEVEL
		li t1, 2
		sw t1, 0(t0)
		
		la t0, MATRIZ_MAPA2
		la t1, CURRENT_MAP_MATRIX
		sw t0, 0(t1)			
		la t0, MAPA2
		la t1, CURRENT_MAP_BG
		sw t0, 0(t1)			
		
		li t1, 32
		li t2, 208
		la t0, CHAR_POS
		sh t1, 0(t0)
		sh t2, 2(t0)
		la t0, OLD_CHAR_POS		
		sh t1, 0(t0)
		sh t2, 2(t0)
		
		li t1, 288
		li t2, 112
		la t0, ENEMY_A_POS
		sh t1, 0(t0)
		sh t2, 2(t0)
		la t0, ENEMY_A_OLD_POS	
		sh t1, 0(t0)
		sh t2, 2(t0)
		la t0, ENEMY_A_ACTIVE
		li t1, 1
		sw t1, 0(t0)                

		li t1, 96               
		li t2, 112
		la t0, ENEMY_B_POS
		sh t1, 0(t0)
		sh t2, 2(t0)
		la t0, ENEMY_B_OLD_POS	
		sh t1, 0(t0)
		sh t2, 2(t0)
		la t0, ENEMY_B_ACTIVE
		li t1, 1
		sw t1, 0(t0)

		addi sp, sp, -4
		sw ra, 0(sp)			
		la a0, MAPA2			
		li a1, 0				
		li a2, 0				
		li a3, 0				
		call PRINT			
		li a3, 1				
		call PRINT			
		lw ra, 0(sp)			
		addi sp, sp, 4			
		j FIM_MUDANCA

# -----------------------------------------------------------------
# NOVA LOGICA: MAPA 2 -> MAPA 3 (SÓ ENTRA SE INIMIGOS == 0)
# -----------------------------------------------------------------
CHECKA_FASE_2:
		# Passo 1: Verificar se os inimigos ainda estão vivos
		la t0, ENEMY_A_ACTIVE
		lw t1, 0(t0)
		bnez t1, FIM_MUDANCA		# Se Inimigo A não é 0, sala não está limpa. Sai.
		
		la t0, ENEMY_B_ACTIVE
		lw t1, 0(t0)
		bnez t1, FIM_MUDANCA		# Se Inimigo B não é 0, sala não está limpa. Sai.

		# Passo 2: Calcular o bloco atual do Player para ver se tocou na porta (ID 29)
		la t0, CHAR_POS
		lh t1, 0(t0)			# Player X
		lh t2, 2(t0)			# Player Y
		
		srli t3, t2, 4			# Y / 16
		li t4, 20
		mul t3, t3, t4			# Linha * 20
		srli t4, t1, 4			# X / 16
		add t3, t3, t4			# Índice na matriz
		
		la t4, CURRENT_MAP_MATRIX
		lw t4, 0(t4)			# Aponta para Matriz do Mapa 2
		add t4, t4, t3
		lbu t5, 0(t4)			# Lê o ID do Bloco
		
		li t6, 29			# ID da porta do Mapa 2
		bne t5, t6, FIM_MUDANCA	# Se não pisou no bloco 29, ignora
		
		# =========================================================
		# GATILHO ATIVADO: PORTA ENCONTRADA E INIMIGOS MORTOS!
		# =========================================================
		
		# Atualiza nível para Fase 3
		la t0, CURRENT_LEVEL
		li t1, 3
		sw t1, 0(t0)
		
		# Troca ponteiros lógicos e de background para o Mapa 3
		la t0, MATRIZ_MAPA3
		la t1, CURRENT_MAP_MATRIX
		sw t0, 0(t1)
		
		la t0, MAPA3
		la t1, CURRENT_MAP_BG
		sw t0, 0(t1)
		
		# Posição inicial do Player ao entrar na sala do Chefão (Exemplo: Centro-Baixo)
		li t1, 144
		li t2, 208
		la t0, CHAR_POS
		sh t1, 0(t0)
		sh t2, 2(t0)
		la t0, OLD_CHAR_POS
		sh t1, 0(t0)
		sh t2, 2(t0)
		
		# --- INICIALIZAÇÃO DO CHEFÃO (Mapa 3) ---
		li t1, 144                      # X inicial do Boss (Meio da tela)
		li t2, 48                       # Y inicial do Boss (Parte superior)
		la t0, BOSS_POS
		sh t1, 0(t0)
		sh t2, 2(t0)
		la t0, BOSS_OLD_POS	
		sh t1, 0(t0)
		sh t2, 2(t0)
		
		la t0, BOSS_ACTIVE
		li t1, 1
		sw t1, 0(t0)                    # Ativa o Chefão! (BOSS_ACTIVE = 1)
		
		# Carimba o background do MAPA3 em ambos os frames para evitar flicker
		addi sp, sp, -4
		sw ra, 0(sp)
		
		la a0, MAPA3
		li a1, 0
		li a2, 0
		
		li a3, 0
		call PRINT			# Roda frame 0
		
		li a3, 1
		call PRINT			# Roda frame 1
		
		lw ra, 0(sp)
		addi sp, sp, 4

FIM_MUDANCA:
		ret
		
# =================================================================
# IA DO CHEFÃO: MOVIMENTO E GATILHO DE DISPARO
# =================================================================
ATUALIZA_BOSS:
		la t0, BOSS_ACTIVE
		lw t1, 0(t0)
		li t2, 1
		bne t1, t2, FIM_ATUALIZA_BOSS	# Só processa se o Boss estiver ativo (1)
		
		# --- 1. CONTROLE DE VELOCIDADE DO PASSO ---
		la t0, BOSS_COUNT
		lw t1, 0(t0)
		addi t1, t1, 1
		sw t1, 0(t0)
		
		la t2, BOSS_SPEED
		lw t2, 0(t2)
		blt t1, t2, CHECK_BOSS_FIRE	# Se não deu o tempo de andar, pula direto pro tiro
		
		sw zero, 0(t0)			# Reseta cronômetro do passo
		
		# --- 2. IA DE MOVIMENTO (PERSEGUIÇÃO) ---
		addi sp, sp, -4
		sw ra, 0(sp)
		
		la t0, BOSS_POS
		lh t3, 0(t0)			# t3 = Boss X
		lh t4, 2(t0)			# t4 = Boss Y
		
		# Carimba a posição atual no rastro antigo antes de andar
		la t1, BOSS_OLD_POS
		lw t2, 0(t0)
		sw t2, 0(t1)
		
		la t1, CHAR_POS
		lh t5, 0(t1)			# t5 = Player X
		lh t6, 2(t1)			# t6 = Player Y
		
		beq t3, t5, BOSS_IA_Y		
		blt t3, t5, BOSS_IA_DIR		
BOSS_IA_ESQ:	addi t3, t3, -16
		j CHK_COLISAO_BOSS
BOSS_IA_DIR:	addi t3, t3, 16
		j CHK_COLISAO_BOSS

BOSS_IA_Y:	beq t4, t6, RESTAURA_PILHA_BOSS	# <--- CORREÇÃO: Vai para a label que limpa a pilha!
		blt t4, t6, BOSS_IA_BAIXO
BOSS_IA_CIMA:	addi t4, t4, -16
		j CHK_COLISAO_BOSS
BOSS_IA_BAIXO:	addi t4, t4, 16

CHK_COLISAO_BOSS:
		srli t1, t4, 4			
		li t2, 20
		mul t1, t1, t2			
		srli t2, t3, 4			
		add t1, t1, t2			
		
		la t2, CURRENT_MAP_MATRIX
		lw t2, 0(t2)
		add t2, t2, t1
		lbu t1, 0(t2)			
		
		beq t1, zero, RESTAURA_PILHA_BOSS # <--- CORREÇÃO: Limpa a pilha se colidir
		
		# Grava a nova posição válida
		la t0, BOSS_POS
		sh t3, 0(t0)
		sh t4, 2(t0)

RESTAURA_PILHA_BOSS:
		lw ra, 0(sp)
		addi sp, sp, 4
		j CHECK_BOSS_FIRE

# --- 3. LÓGICA DE RECARGA E MIRA AUTOMÁTICA DO TIRO ---
CHECK_BOSS_FIRE:
		la t0, BOSS_FIRE_COUNT
		lw t1, 0(t0)
		addi t1, t1, 1
		sw t1, 0(t0)
		
		la t2, BOSS_FIRE_RATE
		lw t2, 0(t2)
		blt t1, t2, DESENHA_BOSS	# Ainda recarregando...
		
		la t2, BOSS_BULLET_ACTIVE
		lw t3, 0(t2)
		bnez t3, DESENHA_BOSS		# Se já tem um tiro verde na tela, espera
		
		sw zero, 0(t0)			# Reseta o tempo de recarga
		li t3, 1
		sw t3, 0(t2)			# Ativa o tiro (BOSS_BULLET_ACTIVE = 1)
		
		la t2, BOSS_POS
		lw t3, 0(t2)
		la t4, BOSS_BULLET_POS
		sw t3, 0(t4)			# Projétil nasce na coordenada central do Boss
		
		lh t3, 0(t2)			# BX
		lh t4, 2(t2)			# BY
		la t1, CHAR_POS
		lh t5, 0(t1)			# PX
		lh t6, 2(t1)			# PY
		
		# Algoritmo de Mira em Cruz (Ortogonal) baseado na maior distância
		sub t1, t5, t3			# t1 = dx (PX - BX)
		sub t2, t6, t4			# t2 = dy (PY - BY)
		bgez t1, BX_POS
		sub t1, zero, t1		# t1 = |dx|
BX_POS:		bgez t2, BY_POS
		sub t2, zero, t2		# t2 = |dy|
BY_POS:		blt t1, t2, BMIRA_Y
BMIRA_X:	blt t3, t5, BDISP_DIR
BDISP_ESQ:	li t1, 3			# Atira para a Esquerda
		j BGRAVA_DIR
BDISP_DIR:	li t1, 4			# Atira para a Direita
		j BGRAVA_DIR
BMIRA_Y:	blt t4, t6, BDISP_BAIXO
BDISP_CIMA:	li t1, 1			# Atira para Cima
		j BGRAVA_DIR
BDISP_BAIXO:	li t1, 2			# Atira para Baixo
BGRAVA_DIR:	la t0, BOSS_BULLET_DIR
		sw t1, 0(t0)

# --- 4. RENDERIZAÇÃO DO SPRITE DO BOSS ---
DESENHA_BOSS:
		addi sp, sp, -4
		sw ra, 0(sp)
		la a0, chefao			# Seu sprite armazenado
		la t0, BOSS_POS
		lh a1, 0(t0)
		lh a2, 2(t0)
		mv a3, s0
		call PRINT
		lw ra, 0(sp)
		addi sp, sp, 4

FIM_ATUALIZA_BOSS:
		ret

# =================================================================
# FÍSICA E COLISÃO DO PROJÉTIL VERDE DO CHEFÃO
# =================================================================
MOVE_BOSS_BULLET:
		la t0, BOSS_BULLET_ACTIVE
		lw t1, 0(t0)
		li t2, 1
		bne t1, t2, FIM_MOVE_BOSS_BULLET # Só move se estiver ativo (1)
		
		la t0, BOSS_BULLET_POS
		lw t1, 0(t0)
		la t2, OLD_BOSS_BULLET_POS
		sw t1, 0(t2)			# Copia posição para histórico de rastro
		
		lh t3, 0(t0)			# Tiro X
		lh t4, 2(t0)			# Tiro Y
		
		la t0, BOSS_BULLET_DIR
		lw t1, 0(t0)
		
		li t2, 1
		beq t1, t2, BB_CIMA
		li t2, 2
		beq t1, t2, BB_BAIXO
		li t2, 3
		beq t1, t2, BB_ESQ
		li t2, 4
		beq t1, t2, BB_DIR
		j FIM_MOVE_BOSS_BULLET

BB_CIMA:	addi t4, t4, -16
		j CHK_BB_COLISAO
BB_BAIXO:	addi t4, t4, 16
		j CHK_BB_COLISAO
BB_ESQ:		addi t3, t3, -16
		j CHK_BB_COLISAO
BB_DIR:		addi t3, t3, 16

CHK_BB_COLISAO:
		# Teste de bordas da tela
		blt t3, zero, BB_MORRE
		li t1, 320
		bge t3, t1, BB_MORRE
		blt t4, zero, BB_MORRE
		li t1, 240
		bge t4, t1, BB_MORRE
		
		# Teste de colisão com a Matriz 3
		srli t1, t4, 4
		li t2, 20
		mul t1, t1, t2
		srli t2, t3, 4
		add t1, t1, t2
		la t2, CURRENT_MAP_MATRIX
		lw t2, 0(t2)
		add t2, t2, t1
		lbu t1, 0(t2)
		beq t1, zero, BB_MORRE		# Bateu em parede lógica, apaga o tiro
		
		# --- SUBSTITUA APENAS O TRECHO DE IMPACTO EM MOVE_BOSS_BULLET ---
		la t0, CHAR_POS
		lh t1, 0(t0)
		lh t2, 2(t0)
		bne t3, t1, BB_SUCESSO		
		bne t4, t2, BB_SUCESSO		
		
		# IMPACTO!
		la t0, BOSS_BULLET_ACTIVE
		li t1, 2
		sw t1, 0(t0)			# Coloca o tiro para sumir no próximo frame
		
		addi sp, sp, -4
		sw ra, 0(sp)
		
		la a0, CHAR_POS			# Alvo do reset é o Player
		la a1, OLD_CHAR_POS
		li a2, 144				# X inicial do player no mapa 3
		li a3, 208				# Y inicial do player no mapa 3
		call APLICA_DANO_LOGICA		
		
		lw ra, 0(sp)
		addi sp, sp, 4
		j FIM_MOVE_BOSS_BULLET

BB_SUCESSO:
		la t0, BOSS_BULLET_POS
		sh t3, 0(t0)
		sh t4, 2(t0)
		j FIM_MOVE_BOSS_BULLET

BB_MORRE:	la t0, BOSS_BULLET_ACTIVE
		li t1, 2
		sw t1, 0(t0)			# Inicia protocolo de sumiço do tiro

FIM_MOVE_BOSS_BULLET:
		ret

# =================================================================
# RENDERS E LIMPADORES DE RASTRO ADICIONAIS DO BOSS
# =================================================================
DESENHA_BOSS_BULLET:
		la t0, BOSS_BULLET_ACTIVE
		lw t1, 0(t0)
		li t2, 1
		bne t1, t2, FIM_DRAW_BB
		
		la t0, BOSS_BULLET_POS
		la a0, chefao_tiro		# Sua textura verde
		lh a1, 0(t0)
		lh a2, 2(t0)
		mv a3, s0
		
		addi sp, sp, -4
		sw ra, 0(sp)
		call PRINT
		lw ra, 0(sp)
		addi sp, sp, 4
FIM_DRAW_BB:	ret

LIMPA_RASTRO_BOSS:
		la t0, BOSS_ACTIVE
		lw t1, 0(t0)
		beq t1, zero, FIM_L_BOSS
		
		la t0, BOSS_OLD_POS
		lh a1, 0(t0)
		lh a2, 2(t0)
		addi sp, sp, -4
		sw ra, 0(sp)
		call ENCONTRA_TEXTURA
		lw ra, 0(sp)
		addi sp, sp, 4
FIM_L_BOSS:	ret

# =================================================================
# LIMPEZA DO RASTRO DO TIRO VERDE DO CHEFÃO
# =================================================================
LIMPA_RASTRO_BOSS_BULLET:
		la t0, BOSS_BULLET_ACTIVE
		lw t1, 0(t0)
		beq t1, zero, FIM_L_BB		# Se inativo (0), não faz nada
		
		# Salva estado atual na pilha
		addi sp, sp, -4
		sw t1, 0(sp)
		
		# Prepara coordenadas antigas para o restaurador de texturas
		la t0, OLD_BOSS_BULLET_POS
		lh a1, 0(t0)
		lh a2, 2(t0)
		
		addi sp, sp, -4
		sw ra, 0(sp)
		call ENCONTRA_TEXTURA		# Restaura o piso correspondente
		lw ra, 0(sp)
		addi sp, sp, 4
		
		lw t1, 0(sp)
		addi sp, sp, 4
		
		# --- MÁQUINA DE ESTADOS DO DOUBLE BUFFERING ---
		li t2, 2
		beq t1, t2, BB_VA_PARA_3
		li t2, 3
		beq t1, t2, BB_VA_PARA_0
		j FIM_L_BB

BB_VA_PARA_3:
		la t0, BOSS_BULLET_ACTIVE
		li t1, 3
		sw t1, 0(t0)			# Configura para limpar o segundo frame no próximo ciclo
		j FIM_L_BB

BB_VA_PARA_0:
		la t0, BOSS_BULLET_ACTIVE
		sw zero, 0(t0)			# Com os dois frames limpos, zera o status para novo disparo

FIM_L_BB:	ret


# =================================================================
# ESPERA UM DETERMINADO NÚMERO DE FRAMES (DELAY LÓGICO)
# Entrada: a0 = quantidade de frames para esperar
# =================================================================
ESPERA_FRAMES:
		li t0, 0
LOOP_DELAY_OUTER:
		beq t0, a0, FIM_DELAY
		
		# Este loop interno serve para gastar tempo do processador.
		# Como o RARS simula muito rápido, precisamos contar até um número alto
		# para dar a sensação de 1 frame de atraso na percepção humana.
		li t1, 0
		li t2, 6000             # Ajuste este número se achar o delay muito longo/curto
LOOP_DELAY_INNER:
		addi t1, t1, 1
		blt t1, t2, LOOP_DELAY_INNER
		
		addi t0, t0, 1
		j LOOP_DELAY_OUTER
FIM_DELAY:
		ret
