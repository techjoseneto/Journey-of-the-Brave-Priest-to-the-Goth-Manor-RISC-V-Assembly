.data

#FASE
CURRENT_LEVEL:       .word 1       # Comeca na Fase 1
CURRENT_MAP_MATRIX:  .word 0       # Ponteiro para a matriz logica ativa
CURRENT_MAP_BG:      .word 0       # Ponteiro para a textura de fundo ativa

#POSICAO DO PLAYER/JOGADOR
CHAR_POS:	.half 160,208			# x, y iniciais do personagem
OLD_CHAR_POS:	.half 160,208			# x, y do personagem

#POSICAO E DADOS SOBRE OS INIMIGOS DA FASE 2
ENEMY_A_COUNT:          .word 0
ENEMY_B_COUNT:          .word 0       
ENEMY_SPEED:          .word 10     

TOTAL_DEFEATED:       .word 0       # Quantas vezes os inimigos morreram no total
SPAWN_INDEX:          .word 0       # Proximo ponto de nascimento usado

# tabela de nascimentos
SPAWN_POINTS:
    .half 288, 32                   # Ponto 0: Canto superior direito
    .half 160, 112                    # Ponto 1: Lateral esquerda
    .half 128, 112                  # Ponto 2: Centro do mapa
    .half 288, 192                  # Ponto 3: Canto inferior direito

# inimigo A
ENEMY_A_POS:          .half 0, 0    # Coordenadas X, Y atuais do Inimigo A
ENEMY_A_OLD_POS:      .half 0, 0    # Coordenadas X, Y do frame anterior (rastro)
ENEMY_A_ACTIVE:       .word 0       # 0 = Inativo (Fase 1), 1 = Ativo (Fase 2)
ENEMY_A_LIVES:        .word 3       # Quantidade de "clones/vidas" restantes

# inimigo B
ENEMY_B_POS:          .half 0, 0    # Coordenadas X, Y atuais do Inimigo B
ENEMY_B_OLD_POS:      .half 0, 0    # Coordenadas X, Y do frame anterior (rastro)
ENEMY_B_ACTIVE:       .word 0       # 0 = Inativo (Fase 1), 1 = Ativo (Fase 2)
ENEMY_B_LIVES:        .word 3       # Quantidade de "clones/vidas" restantes

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
		call VERIFICA_DANO_PLAYER	# Checa se as coordenadas do inimigo sao iguais a do player	
		call VERIFICA_MUDANCA_FASE   	# Sempre de olho se o player passou de fase
		
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
		# =========================================================
		
		# --- DESENHA PERSONAGEM ---
		la t0, CHAR_POS			
		la a0, char			
		lh a1, 0(t0)			
		lh a2, 2(t0)			
		mv a3, s0			
		call PRINT			
		
		# --- DESENHA TIRO ---	
		call DESENHA_BULLET		
		
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
		
		call LIMPA_RASTRO_BULLET	

		j GAME_LOOP
		
.data
#Anexo de arquivos
.include "funcoes.s"

.include "mapas_e_matrizes/mapa1.s"
.include "mapas_e_matrizes/matriz_mapa1.s"

.include "mapas_e_matrizes/mapa2.s"
.include "mapas_e_matrizes/matriz_mapa2.s"

#Anexo de texturas
.include "sprites/char.s"
.include "sprites/inimigoA.s"
.include "sprites/inimigoB.s"

.include "texturas/cenario1_cerca.s"
.include "texturas/cenario1_grama.s"
.include "texturas/cenario1_parede.s"

.include "texturas/cenario2_marrom.s"
.include "texturas/cenario2_vermelhoescuro.s"
.include "texturas/cenario2_vermelhoclaro.s"
.include "texturas/cenario2_branco.s"
.include "texturas/cenario2_verde.s"

