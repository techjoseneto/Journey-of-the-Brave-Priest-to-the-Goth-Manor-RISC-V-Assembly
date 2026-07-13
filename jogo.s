.data

#FASE
CURRENT_LEVEL:       .word 1       # Comeca na Fase 1
CURRENT_MAP_MATRIX:  .word 0       # Ponteiro para a matriz logica ativa
CURRENT_MAP_BG:      .word 0       # Ponteiro para a textura de fundo ativa

#VIDA
BASE_ADDRESS: .word 268697600
HEART_POS:    .half 0, 0		 # X, Y

#POSICAO DO PLAYER/JOGADOR
CHAR_POS:	.half 144,144			# x, y iniciais do personagem
OLD_CHAR_POS:	.half 144,144			# x, y do personagem

#POSICAO E DADOS SOBRE OS INIMIGOS DA FASE 2
ENEMY_A_COUNT:          .word 0
ENEMY_B_COUNT:          .word 0       
ENEMY_SPEED:          .word 80    

TOTAL_DEFEATED:       .word 0       # Quantas vezes os inimigos morreram no total
SPAWN_INDEX:          .word 0       # Proximo ponto de nascimento usado

# tabela de nascimentos
SPAWN_POINTS:
    .half 32, 48                   # Ponto 0: Canto superior direito
    .half 160, 48                    # Ponto 1: Lateral esquerda
    .half 128, 112                  # Ponto 2: Centro do mapa
    .half 224, 192                  # Ponto 3: Canto inferior direito

# inimigo A
ENEMY_A_POS:          .half 0, 0    # Coordenadas X, Y atuais do Inimigo A
ENEMY_A_OLD_POS:      .half 0, 0    # Coordenadas X, Y do frame anterior (rastro)
ENEMY_A_ACTIVE:       .word 0       # 0 = Inativo (Fase 1), 1 = Ativo (Fase 2)
ENEMY_A_LIVES:        .word 4       # Quantidade de "clones/vidas" restantes

# inimigo B
ENEMY_B_POS:          .half 0, 0    # Coordenadas X, Y atuais do Inimigo B
ENEMY_B_OLD_POS:      .half 0, 0    # Coordenadas X, Y do frame anterior (rastro)
ENEMY_B_ACTIVE:       .word 0       # 0 = Inativo (Fase 1), 1 = Ativo (Fase 2)
ENEMY_B_LIVES:        .word 4       # Quantidade de "clones/vidas" restantes

# =================================================================
# VARIÁVEIS DO CHEFÃO (FASE 3)
# =================================================================
BOSS_POS:             .half 144, 48    # Coordenadas X, Y iniciais do Chefão (Topo centro)
BOSS_OLD_POS:         .half 144, 48    # Coordenadas para limpeza de rastro
BOSS_ACTIVE:          .word 0          # 0 = Inativo (Fases 1 e 2), 1 = Ativo (Fase 3), 2/3 = Sequência de morte
BOSS_LIVES:           .word 1         # O Chefão aguenta 12 tiros do jogador!
BOSS_COUNT:           .word 0          # Contador de velocidade do Boss
BOSS_SPEED:           .word 40         # Um pouco mais rápido que os lacaios (que eram 50)
BOSS_DEATH_TIMER:     .word 0

# --- SISTEMA DE TIRO DO CHEFÃO ---
BOSS_BULLET_POS:      .half 0, 0       # Posição X, Y do tiro do boss
OLD_BOSS_BULLET_POS:  .half 0, 0       # Rastro do tiro do boss
BOSS_BULLET_ACTIVE:   .word 0          # 0 = Inativo, 1 = Ativo, 2/3 = Sequência de limpeza
BOSS_BULLET_DIR:      .word 0          # 1=Cima, 2=Baixo, 3=Esquerda, 4=Direita
BOSS_FIRE_COUNT:      .word 0          # Cronômetro/Timer para controlar a cadência de tiro do Boss
BOSS_FIRE_RATE:       .word 300        # Intervalo entre os tiros do Boss (ajustável)

#Vidas do player/jogador
PLAYER_LIVES:	.word 3				# Vidas do jogador (Comeca com 3)
PLAYER_DEATH_POS:     .half 0, 0    		# Guarda as coordenadas de onde o player morreu
PLAYER_RESPAWN_COUNT: .word 0    		# Limpa os frames das coordenadas de onde o player morreu

#Ataque dos inimigos
ENEMY_DEATH_POS:      .half 0, 0    		# Guarda onde o inimigo bateu no player
ENEMY_PENULTIMA_POS:  .half 0, 0		# Guarda a ultima posicao antes do inimigo bater no player
ENEMY_RESPAWN_COUNT:  .word 0    		# Contador de 2 frames para limpar o fantasma do inimigo

#Ultima direcao do jogador (para definir a direcao do tiro)
CHAR_LOOK_DIR:   .word 4               # 1=Cima, 2=Baixo, 3=Esquerda, 4=Direita (Padrão: Direita)

#Sistema de tiro
BULLET_POS:	.half 0, 0			# Posição X, Y do tiro
OLD_BULLET_POS:	.half 0, 0			# Rastro do tiro
BULLET_ACTIVE:	.word 0				# 0 = Inativo, 1 = Ativo na tela
BULLET_DIR:	.word 0				# Para onde o tiro está voando

.text

HISTORIA:	# --- EXIBE A TELA DA HISTÓRIA 1 ---
	        la a0, comecotxt        # Endereço da imagem/texto da história 1
	        li a1, 0                # X = 0
	        li a2, 0                # Y = 0
	        li a3, 0                
	        call PRINT
	        li a3, 1                
	        call PRINT
	        call WAIT_SPACE         # Trava o jogo até o jogador apertar Espaço
	        # --- EXIBE A TELA DA HISTÓRIA 2 ---
	        la a0, ajudatxt         # Endereço da imagem/texto da história 2
	        li a1, 0
	        li a2, 0
	        li a3, 0
	        call PRINT
	        li a3, 1
	        call PRINT
	        call WAIT_SPACE         # Trava o jogo até o jogador apertar Espaço novamente
	        # --- LIMPA A TELA REDESENHANDO O MAPA ANTES DE INICIAR O JOGO ---
	        j SETUP


# Esse setup serve pra desenhar o mapa 1 nos dois frames antes do "jogo" comecar
SETUP:		la t0, MATRIZ_MAPA1
		la t1, CURRENT_MAP_MATRIX
		sw t0, 0(t1)
		
		la t0, MAPA1
		la t1, CURRENT_MAP_BG
		sw t0, 0(t1)

		# Desenha o fundo inicial baseado no ponteiro dinâmico
		lw a0, 0(t1)			# Carrega o MAPA1
		li a1,0				
		li a2,0				
		li a3,0				
		call PRINT			
		li a3,1				
		call PRINT

GAME_LOOP:	
		call KEY2			# Tecla do jogador para mover o player

		call MOVE_BULLET		# Movimentacao do tiro
		call MOVE_BOSS_BULLET
		call VERIFICA_DANO_PLAYER	# Checa se as coordenadas do inimigo sao iguais a do player	
		call VERIFICA_MUDANCA_FASE   	# Sempre de olho se o player passou de fase
		call VERIFICA_DANO_BOSS
		
		# --- TROCA DE FRAME ANTES DAS RENDERIZAÇÕES ---
		xori s0, s0, 1			# Inverte o frame atual (Double Buffering perfeito)
		
		# =========================================================
		# PROCESSAMENTO DA DUPLA DE INIMIGOS
		# =========================================================
		# --- PROCESSA INIMIGO A (Move e Desenha) ---
		la a0, ENEMY_A_POS          
		la a1, ENEMY_A_OLD_POS      
		la a2, ENEMY_A_ACTIVE       
		mv a3, s0     
		la a4, ENEMY_A_COUNT              
		call ATUALIZA_INIMIGO
		
		# --- PROCESSA INIMIGO B (Move e Desenha) ---
		la a0, ENEMY_B_POS          
		la a1, ENEMY_B_OLD_POS      
		la a2, ENEMY_B_ACTIVE       
		mv a3, s0        
		la a4, ENEMY_B_COUNT           
		call ATUALIZA_INIMIGO
		
		# --- CHEFÃO DO MAPA 3 ---
		call ATUALIZA_BOSS
		# =========================================================
		
		# --- DESENHA PERSONAGEM ---
		la t0, CHAR_POS			
		la a0, char			
		lh a1, 0(t0)			
		lh a2, 2(t0)			
		mv a3, s0			
		call PRINT
		
		# --- DESENHA VIDA (Loop Dinâmico com Limpeza) ---
            	la t0, HEART_POS            
	        lh a1, 0(t0)                 # a1 = X inicial (0)
	        lh a2, 2(t0)                 # a2 = Y inicial (0)
	        li t1, 3                     # t1 = Máximo de vidas possíveis (para limpar o rastro)
        	LOOP_LIMPA_CORACOES:
            	# Salva registradores antes do PRINT
            	addi sp, sp, -12
            	sw t1, 8(sp)
            	sw a2, 4(sp)
            	sw a1, 0(sp)
            	# Carrega a textura de fundo ou grama para cobrir o coração antigo
            	# DICA: Substitua 'cenario1_grama' pela textura que faz sentido ficar atrás da HUD
            	la a0, preto   
            	mv a3, s0                    # Limpa apenas no frame invertido atual (s0)
            	call PRINT
            	# Restaura e avança para a próxima posição
            	lw a1, 0(sp)
            	lw a2, 4(sp)
            	lw t1, 8(sp)
            	addi sp, sp, 12
            	addi a1, a1, 16              # Avança X para a próxima posição de coração
            	addi t1, t1, -1              # Decrementa o limpador
            	bnez t1, LOOP_LIMPA_CORACOES
        	# --- AGORA DESENHA OS CORAÇÕES ATIVOS ---
            	lw t1, PLAYER_LIVES          # t1 = Quantidade de vidas atuais (ex: 2)
            	blez t1, FIM_DESENHO_VIDA    # Se vida <= 0, não desenha nada
            	la t0, HEART_POS            
            	lh a1, 0(t0)                 # Reseta X para 0
            	lh a2, 2(t0)                 # Reseta Y para 0
        	LOOP_CORACOES:
            	addi sp, sp, -12
            	sw t1, 8(sp)
            	sw a2, 4(sp)
            	sw a1, 0(sp)
            	# Desenha o coração no Buffer atual (s0) para acompanhar o ritmo do jogo
            	la a0, vermelho              
            	mv a3, s0                    
            	call PRINT
            	# Restaura e avança
            	lw a1, 0(sp)
            	lw a2, 4(sp)
            	lw t1, 8(sp)
            	addi sp, sp, 12
            	addi a1, a1, 16              
            	addi t1, t1, -1              
            	bnez t1, LOOP_CORACOES       
		FIM_DESENHO_VIDA:			
		
		# --- DESENHA TIRO ---	
		call DESENHA_BULLET
		call DESENHA_BOSS_BULLET		
		
		# --- EXIBE O FRAME ATUALIZADO NO DISPLAY ---
		li t0, 0xFF200604		
		sw s0, 0(t0)			
		
		# --- LIMPEZA DE RASTROS NO FRAME INVERSO ---
		call LIMPA_RASTRO_PLAYER	
		
		# --- LIMPA RASTRO DOS DOIS INIMIGOS ---
		la a0, ENEMY_A_OLD_POS
		la a1, ENEMY_A_ACTIVE
		call LIMPA_RASTRO_INIMIGO
		
		la a0, ENEMY_B_OLD_POS
		la a1, ENEMY_B_ACTIVE
		call LIMPA_RASTRO_INIMIGO
		
		call LIMPA_RASTRO_BOSS
		
		# --- LIMPA RASTRO DOS TIROS ---
		call LIMPA_RASTRO_BULLET
		call LIMPA_RASTRO_BOSS_BULLET	

		call VERIFICA_DEATH_TIMER

		j GAME_LOOP

FIM: 		li a0, 10
		ecall
		
.data
#Anexo de arquivos
.include "funcoes.s"

.include "mapas_e_matrizes/mapa1.s"
.include "mapas_e_matrizes/matriz_mapa1.s"

.include "mapas_e_matrizes/mapa2.s"
.include "mapas_e_matrizes/matriz_mapa2.s"

.include "mapas_e_matrizes/mapa3.s"
.include "mapas_e_matrizes/matriz_mapa3.s"

#Anexo da historia
.include "historia/comecotxt.s"
.include "historia/ajudatxt.s"
.include "historia/vitoriatxt.s"
.include "historia/derrotatxt.s"

#Anexo de texturas
.include "sprites/char.s"
.include "sprites/inimigoA.s"
.include "sprites/inimigoB.s"
.include "sprites/chefao.s"

.include "texturas/vermelho.s"
.include "texturas/preto.s"

.include "texturas/cenario1_pedra_esquerda.s"
.include "texturas/cenario1_pedra_direita.s"
.include "texturas/cenario1_escada_esquerda.s"
.include "texturas/cenario1_escada_direita.s"


.include "texturas/cenario2_branco.s"
.include "texturas/cenario2_piso.s"


.include "texturas/cenario3_piso.s"
.include "texturas/chefao_tiro.s"
