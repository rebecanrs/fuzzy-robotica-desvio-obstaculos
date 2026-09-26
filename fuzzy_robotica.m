% =========================================================================
% Atividade Prática 3A: Robótica Móvel
% Implementação Algébrica de Inferência Fuzzy Mamdani e CDA
% =========================================================================
clear; clc; close all;

%% 1. Entradas de Teste (Sensores)
d_in = 10;   % Distância frontal (cm)
a_in = -10;  % Assimetria lateral (cm)

fprintf('====================================================\n');
fprintf('  CONTROLE FUZZY ROBÓTICA - EXECUÇÃO NATIVA         \n');
fprintf('====================================================\n');
fprintf('Entrada Distância : %6.2f cm\n', d_in);
fprintf('Entrada Assimetria: %6.2f cm\n', a_in);

%% 2. Fase 1: Fuzzificação das Entradas
% Equações analíticas das funções de pertinência
% Variável 1: Distância frontal d (0 a 100)
mu_d_Perto = max(0, min(1, (40 - d_in)/25));
mu_d_Media = max(0, min((d_in - 15)/35, (85 - d_in)/35));
mu_d_Longe = max(0, min(1, (d_in - 60)/25));

% Variável 2: Assimetria a (-50 a 50)
mu_a_Neg  = max(0, min(1, -a_in/25));
mu_a_Zero = max(0, min((a_in + 25)/25, (25 - a_in)/25));
mu_a_Pos  = max(0, min(1, a_in/25));

fprintf('\n[FASE 1: FUZZIFICAÇÃO]\n');
fprintf('Perto = %.2f | Media = %.2f | Longe = %.2f\n', mu_d_Perto, mu_d_Media, mu_d_Longe);
fprintf('Negativa = %.2f | Zero = %.2f | Positiva = %.2f\n', mu_a_Neg, mu_a_Zero, mu_a_Pos);

%% 3. Fase 2 e 3: Regras e Implicação de Mamdani
% Universo de discurso da saída (Ângulo de -45 a 45, passo de 5 graus)
theta_grid = -45:5:45;

% Funções de pertinência da saída
mu_t_Esq = max(0, min(1, -theta_grid/20));
mu_t_Seg = max(0, min((theta_grid + 20)/20, (20 - theta_grid)/20));
mu_t_Dir = max(0, min(1, theta_grid/20));

% Base de Regras (Operador Mínimo para o conectivo E)
% Regras para Virar Esquerda (R1, R4)
w_Esq = max([min(mu_d_Perto, mu_a_Neg), min(mu_d_Media, mu_a_Neg)]);

% Regras para Seguir em Frente (R5, R7, R8, R9)
w_Seguir = max([min(mu_d_Media, mu_a_Zero), min(mu_d_Longe, mu_a_Neg), ...
    min(mu_d_Longe, mu_a_Zero), min(mu_d_Longe, mu_a_Pos)]);

% Regras para Virar Direita (R2, R3, R6)
w_Dir = max([min(mu_d_Perto, mu_a_Zero), min(mu_d_Perto, mu_a_Pos), min(mu_d_Media, mu_a_Pos)]);

fprintf('\n[FASE 2 E 3: FORÇA DAS REGRAS]\n');
fprintf('Força "Virar Esq." : %.2f\n', w_Esq);
fprintf('Força "Seguir"     : %.2f\n', w_Seguir);
fprintf('Força "Virar Dir." : %.2f\n', w_Dir);

%% 4. Fase 4: Agregação (Operador Máximo)
mu_C_Esq = min(w_Esq, mu_t_Esq);
mu_C_Seg = min(w_Seguir, mu_t_Seg);
mu_C_Dir = min(w_Dir, mu_t_Dir);

mu_agg = max(mu_C_Esq, max(mu_C_Seg, mu_C_Dir));

%% 5. Fase 5: Defuzzificação por Centro de Área (CDA)
soma_numerador   = sum(mu_agg .* theta_grid);
soma_denominador = sum(mu_agg);

theta_crisp = soma_numerador / soma_denominador;

fprintf('\n[FASE 4 E 5: DEFUZZIFICAÇÃO]\n');
fprintf('Somatório do Numerador   : %8.2f\n', soma_numerador);
fprintf('Somatório do Denominador : %8.2f\n', soma_denominador);
fprintf('ÂNGULO FINAL CALCULADO   : %8.4f graus\n', theta_crisp);
fprintf('====================================================\n');

%% 6. Gráfico da Região Agregada (Para print do relatório)
figure('Color', [1 1 1], 'Position', [100 100 700 400]);
plot(theta_grid, mu_t_Esq, 'k--', 'LineWidth', 1); hold on;
plot(theta_grid, mu_t_Seg, 'Color', [0.85 0.65 0.13], 'LineStyle', '--', 'LineWidth', 1);
plot(theta_grid, mu_t_Dir, 'g--', 'LineWidth', 1);
area(theta_grid, mu_agg, 'FaceColor', [0.2 0.6 1.0], 'FaceAlpha', 0.5, 'EdgeColor', 'b', 'LineWidth', 2);
plot([theta_crisp theta_crisp], [0 1], 'r-', 'LineWidth', 2);
plot(theta_crisp, 0.25, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
grid on;
title(sprintf('Região Agregada e Centro de Área (\\theta = %.2f^{\\circ})', theta_crisp), 'FontSize', 12);
xlabel('Ângulo de direção \theta (graus)');
ylabel('Grau de Pertinência \mu');
legend('Esquerda', 'Seguir', 'Direita', 'Saída Agregada', 'CDA Final', 'Location', 'NorthEast');
xlim([-45 45]); ylim([0 1.05]);