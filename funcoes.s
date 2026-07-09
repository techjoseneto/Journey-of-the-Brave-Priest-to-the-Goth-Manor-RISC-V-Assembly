# =================================================================
# funcoes.s - Todas as subrotinas do jogo reunidas
# =================================================================
.text

# =================================================================
# SISTEMA DE TECLADO E ENTRADA (JOGADOR)
# =================================================================
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
		
TEXTURAS_FASE1:
		# Mapa 1: Qualquer piso livre (Grama 11 ou Porta 19) usa o fundo padrão do cenario 1
		la a0, cenario1_grama
		j DESENHA_RASTRO
		
TEXTURAS_FASE2:
		# CORREÇÃO: Aponta para as labels de código corretas (TXT_M2_...)
		li t6, 21
		beq t5, t6, TXT_M2_MARROM
		li t6, 22
		beq t5, t6, TXT_M2_VERMELHOCLARO
		li t6, 23
		beq t5, t6, TXT_M2_VERMELHOESCURO
		
		la a0, cenario2_marrom		# Padrão de segurança caso passe em cima de outro valor
		j DESENHA_RASTRO

TXT_M2_MARROM:        la a0, cenario2_marrom		
                      j DESENHA_RASTRO
TXT_M2_VERMELHOCLARO: la a0, cenario2_vermelhoclaro    # Corrigido: adicionado "cenario2_"
                      j DESENHA_RASTRO
TXT_M2_VERMELHOESCURO: la a0, cenario2_vermelhoescuro  # Corrigido: adicionado "cenario2_"
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
		li a3, 32			# Y de reset do A
		j APLICA_DANO_LOGICA

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
		
		# Se as vidas acabarem, vai para tela de derrota
		blez t1, TELA_GAME_OVER
		
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
		
		# CORREÇÃO: Salva X (a2) e Y (a3) corretamente sem misturar os dados
		sh a2, 0(a0)	# Define o novo X na posição atual
		sh a3, 2(a0)	# Define o novo Y na posição atual
		sh a2, 0(a1)	# Define o novo X na posição antiga (rastro)
		sh a3, 2(a1)	# Define o novo Y na posição antiga (rastro)

FIM_VERIFICA_DANO:
		ret

# --- LOOP DE GAME OVER ---
TELA_GAME_OVER:
		j TELA_GAME_OVER
		
		
# =================================================================
# MUDANCA DE FASE
# =================================================================
		
# =================================================================
# MUDANÇA DE FASE E TRANSIÇÃO DE CENÁRIO
# =================================================================
VERIFICA_MUDANCA_FASE:
		# 1. CHECAGEM DE SEGURANÇA
		# Só checa a transição se o jogador ainda estiver na Fase 1
		la t0, CURRENT_LEVEL
		lw t1, 0(t0)
		li t2, 1
		bne t1, t2, FIM_MUDANCA
		
		# 2. CALCULA O BLOCO ONDE O PLAYER ESTÁ PISANDO
		la t0, CHAR_POS
		lh t1, 0(t0)			# t1 = Player X (em pixels)
		lh t2, 2(t0)			# t2 = Player Y (em pixels)
		
		srli t3, t2, 4			# Y / 16 (converte pixels para linha da matriz)
		li t4, 20				# Largura da matriz lógica (20 blocos)
		mul t3, t3, t4			# Linha * 20
		srli t4, t1, 4			# X / 16 (converte pixels para coluna da matriz)
		add t3, t3, t4			# Índice final na memória = (Linha * 20) + Coluna
		
		la t4, CURRENT_MAP_MATRIX
		lw t4, 0(t4)			# Carrega o endereço base da matriz ativa (Matriz 1)
		add t4, t4, t3			# Avança até a posição exata do player
		lbu t5, 0(t4)			# t5 = Conteúdo do bloco (ID do tile)
		
		# Se o bloco NÃO FOR a porta de saída (ID 19), ignora e sai da função
		li t6, 19			
		bne t5, t6, FIM_MUDANCA	
		
		# =========================================================
		# GATILHO ATIVADO: O PLAYER PISOU NA PORTA! TRANSIÇÃO PARA FASE 2
		# =========================================================
		
		# PASSO A: Atualiza a variável de nível para Fase 2
		la t0, CURRENT_LEVEL
		li t1, 2
		sw t1, 0(t0)
		
		# PASSO B: Atualiza os ponteiros dinâmicos do motor do jogo
		la t0, MATRIZ_MAPA2
		la t1, CURRENT_MAP_MATRIX
		sw t0, 0(t1)			# A partir de agora, o jogo lerá as paredes do Mapa 2
		
		la t0, MAPA2
		la t1, CURRENT_MAP_BG
		sw t0, 0(t1)			# O sistema de rastro agora sabe qual é o novo fundo
		
		# PASSO C: Reposiciona os personagens no novo mapa
		# Player teleporta para a entrada inferior da Fase 2 (x=32, y=208)
		li t1, 32
		li t2, 208
		la t0, CHAR_POS
		sh t1, 0(t0)
		sh t2, 2(t0)
		la t0, OLD_CHAR_POS		
		sh t1, 0(t0)
		sh t2, 2(t0)
		
		# --- INICIALIZAÇÃO DO INIMIGO A (Nasce no Ponto 0: 288, 32) ---
		li t1, 288
		li t2, 32
		la t0, ENEMY_A_POS
		sh t1, 0(t0)
		sh t2, 2(t0)
		la t0, ENEMY_A_OLD_POS	
		sh t1, 0(t0)
		sh t2, 2(t0)
		
		la t0, ENEMY_A_ACTIVE
		li t1, 1
		sw t1, 0(t0)                # Ativa o Inimigo A

		# --- INICIALIZAÇÃO DO INIMIGO B (Nasce no Ponto 1: 32, 64) ---
		li t1, 160               
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

		# PASSO D: O "ROLO COMPRESSOR" DO DOUBLE BUFFERING
		# Como mudamos completamente de cenário, precisamos carimbar a imagem do MAPA2
		# inteira em AMBOS os frames da tela (0 e 1). Se desenhássemos em um só,
		# a tela ficaria piscando de volta para o Mapa 1 a cada frame do loop.
		addi sp, sp, -4
		sw ra, 0(sp)			# Salva o endereço de retorno na pilha
		
		la a0, MAPA2			# Passa a imagem do Mapa 2 como argumento
		li a1, 0				# X inicial = 0
		li a2, 0				# Y inicial = 0
		
		li a3, 0				# Força o desenho no Frame Buffer 0
		call PRINT			
		
		li a3, 1				# Força o desenho no Frame Buffer 1
		call PRINT			
		
		lw ra, 0(sp)			# Recupera o ra original
		addi sp, sp, 4			# Desaloca o espaço da pilha

FIM_MUDANCA:
		ret
