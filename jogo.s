.data

#Fase
CURRENT_LEVEL:       .word 1       # Comeca na Fase 1
CURRENT_MAP_MATRIX:  .word 0       # Ponteiro para a matriz lógica ativa
CURRENT_MAP_BG:      .word 0       # Ponteiro para a textura de fundo ativa

#Posicao do player/jogador
CHAR_POS:	.half 160,208			# x, y iniciais do personagem
OLD_CHAR_POS:	.half 160,208			# x, y do personagem

#Posicao e informacoes dos inimigos
ENEMY_POS:	.half 32, 32			# x, y iniciais do inimigo
OLD_ENEMY_POS:	.half 32, 32			# x, y do inimigo
ENEMY_COUNT:	.word 0				# Contador de frames interno do inimigo
ENEMY_SPEED:	.word 30			# Quantidade de frames de espera para o inimigo andar (menor = mais rápido)		
ENEMY_ACTIVE:	.word 0				# 1 = Vivo/Ativo, 2 = Fase de limpeza, 0 = Morto/Sumido

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

GAME_LOOP:	call KEY2			# Tecla do jogador para mover o player
		call MOVE_ENEMY			# Movimentacao dos inimigos
		call MOVE_BULLET		# Movimentacao do tiro
		call VERIFICA_DANO_PLAYER	#Checa se as coordenadas do inimigo sao iguais a do player	
		call VERIFICA_MUDANCA_FASE   	#Sempre de olho se o player passou de fase
		
		xori s0,s0,1			# Inverte o frame atual
		
		# --- DESENHA PERSONAGEM ---
		la t0,CHAR_POS			
		la a0,char			
		lh a1,0(t0)			
		lh a2,2(t0)			
		mv a3,s0			
		call PRINT			
		
		# --- DESENHA INIMIGO ---
		la t0, ENEMY_ACTIVE
		lw t1, 0(t0)
		li t2, 1
		bne t1,t2, PULA_DESENHO_ENEMY #Se nao estiver ativo, nao desenha o inimigo
		
		la t0,ENEMY_POS			
		la a0,char			# Nota: Mudar o char do inimigo depois
		lh a1,0(t0)			
		lh a2,2(t0)			
		mv a3,s0			
		call PRINT	
		
PULA_DESENHO_ENEMY:
		# --- DESENHA TIRO ---	
		call DESENHA_BULLET		
		
		# --- EXIBE O FRAME NO DISPLAY ---
		li t0,0xFF200604		
		sw s0,0(t0)			
		
		# --- LIMPEZA DE RASTROS ---
		call LIMPA_RASTRO_PLAYER	
		call LIMPA_RASTRO_ENEMY	
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

.include "texturas/cenario1_cerca.s"
.include "texturas/cenario1_grama.s"
.include "texturas/cenario1_parede.s"

.include "texturas/cenario2_marrom.s"
.include "texturas/cenario2_vermelhoescuro.s"
.include "texturas/cenario2_vermelhoclaro.s"
.include "texturas/cenario2_branco.s"
.include "texturas/cenario2_verde.s"

