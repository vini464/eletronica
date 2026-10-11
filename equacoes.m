% Dados iniciais (Arbitrários):
% Vcc, Ic, Hfe
% Fc_low, Fc_high
%
% Elementos a definir:
% Impedancias (Zin, Zout)
% Ganho
% Resistências (Rc, Re, R1, R2) -> polarização
% Capacitores (C1, C2, C3) -> Passa banda e acoplamento

% Polarização do BJT, aproximando Ie = Ic;
1;

function [R1, R2, Rc, Re] = analiseDC(Vcc, Ic, Hfe)
  Bcc = 110; % menor valor do beta do BJT
  % Tensões ao redor do BJT
  Vce = 0.5*Vcc;
  Ve = 0.1*Vcc;
  Vb = Ve + 0.7;

  % Calculo dos Resistores
  Rc = (Vcc-Vce-Ve)/Ic;
  Re = Ve/Ic;      % considerando Ie = Ic
  R2 = 0.1*Hfe*Re;
  R1 = ((R2*Vcc)/Vb) - R2;

  printf("\n=== RESULTADOS DC ===\n");
  printf("Ib: %.2e A\n", Ic/Hfe);
  printf("Resistores:\n");
  printf("Rc: %.2f ohms\n", Rc);
  printf("Re: %.2f ohms\n", Re);
  printf("R1: %.2f ohms\n", R1);
  printf("R2: %.2f ohms\n", R2);
  printf("Tensões:\n");
  printf("Vce:  %.2f V\n", Vce);
  printf("Ve:  %.2f V\n", Ve);
  printf("Vb:  %.2f V\n", Vb);
end

% Definição dos capacitores nas frequencias de corte 500 Hz e 6 kHz
% E analise das impedâncias e ganho
function [C1, C2, C3, Zin, Zout, A_total] = analiseAC(Vcc, Ic, Hfe, Vt, Fc_low, Fc_high, R1, R2, Re, Rc, Rl)

  % Reatância Complexa
  Z_C = @(C, f) 1 ./ (1i * 2 * pi .* f .* C);
  capacitor_corte = @(fc, r) 1/(2*pi*fc*r);

  % Resistência vista na base do transistor
  re = Vt/Ic;
  req = (R1 * R2 / (R1 + R2)); % Thevenin da base
  req = (req * Hfe*(Re+re)) / (req + Hfe*(Re+re)); % Paralelo com a entrada do BJT

  % Cálculo dos capacitores
  C1 = capacitor_corte(Fc_low, req);
  C2 = capacitor_corte(Fc_high, Rc);
  C3 = capacitor_corte(0.1*Fc_low, Rl);

  % Funções de Impedância Complexa
  Zin  = @(f) req + Z_C(C1, f);
  Zout = @(f) (Rc .* Z_C(C2, f)) ./ (Rc + Z_C(C2, f));

  % Funções de Ganho
  Vin_base = @(f) req ./ Zin(f);
  Av_trans = @(f) -Zout(f) ./ (Re + re);
  A_total  = @(f) Vin_base(f) .* Av_trans(f);
  Ganho_dB = @(f) 20 * log10(abs(A_total(f)));

  % Frequências de interesse
  f_mid = sqrt(Fc_low * Fc_high);
  F_1oct_low = Fc_low / 2;   % 1 oitava abaixo (dividido por 2)
  F_1oct_high = Fc_high * 2; % 1 oitava acima (multiplicado por 2)
  F_2oct_low = Fc_low / 4;   % 2 oitavas abaixo (dividido por 2^2)
  F_2oct_high = Fc_high * 4; % 2 oitavas acima (multiplicado por 2^2)

  printf("\n=== RESULTADOS AC ===\n");
  printf("Capacitores:\n");
  printf("C1: %.2e F\n", C1);
  printf("C2: %.2e F\n", C2);
  printf("C3: %.2e F\n", C3);

  ganho_mid = Ganho_dB(f_mid);
  ganho_low = Ganho_dB(Fc_low);
  ganho_high = Ganho_dB(Fc_high);
  ganho_1oct_low = Ganho_dB(F_1oct_low);
  ganho_2oct_low = Ganho_dB(F_2oct_low);
  ganho_1oct_high = Ganho_dB(F_1oct_high);
  ganho_2oct_high = Ganho_dB(F_2oct_high);

  printf("\n=== GANHO EM dB ===\n");
  printf("Centro da banda (%.0f Hz): %.2f dB (Referência)\n", f_mid, ganho_mid);
  printf("Corte Inferior  (%.0f Hz) : %.2f dB (%.2f dB em relação ao meio da banda)\n",
         Fc_low, ganho_low, ganho_low - ganho_mid);
  printf("Corte Superior  (%.0f Hz): %.2f dB (%.2f dB em relação ao meio da banda)\n",
         Fc_high, ganho_high, ganho_high - ganho_mid);
  printf("1 Oitava Abaixo (%.0f Hz) : %.2f dB (%.2f dB em relação ao meio da banda)\n",
         F_1oct_low, ganho_1oct_low, ganho_1oct_low - ganho_mid);
  printf("1 Oitava Acima  (%.0f Hz): %.2f dB (%.2f dB em relação ao meio da banda)\n",
         F_1oct_high, ganho_1oct_high, ganho_1oct_high - ganho_mid);
  printf("2 Oitavas Abaixo(%.0f Hz) : %.2f dB (%.2f dB em relação ao meio da banda)\n",
         F_2oct_low, ganho_2oct_low, ganho_2oct_low - ganho_mid);
  printf("2 Oitavas Acima (%.0f Hz): %.2f dB (%.2f dB em relação ao meio da banda)\n",
         F_2oct_high, ganho_2oct_high, ganho_2oct_high - ganho_mid);

  % plot passa-faixa
  fq = logspace(1, 5, 1000); % Frequências de 10Hz a 100kHz

  figure(1);
  plot_dB = Ganho_dB(fq);

  semilogx(fq, plot_dB, 'b', 'LineWidth', 2);
  grid on; hold on;
  title('Filtro Passa-Faixa: Resposta em Frequência (Bode)');
  xlabel('Frequência (Hz)');
  ylabel('Ganho (dB)');

  % Marcando os pontos de interesse no gráfico
  plot(f_mid, Ganho_dB(f_mid), 'ko', 'MarkerFaceColor', 'k');
  plot(Fc_low, Ganho_dB(Fc_low), 'ro', 'MarkerFaceColor', 'r');
  plot(Fc_high, Ganho_dB(Fc_high), 'ro', 'MarkerFaceColor', 'r');
  plot(F_1oct_low, Ganho_dB(F_1oct_low), 'go', 'MarkerFaceColor', 'g');
  plot(F_1oct_high, Ganho_dB(F_1oct_high), 'go', 'MarkerFaceColor', 'g');
  plot(F_2oct_low, Ganho_dB(F_2oct_low), 'mo', 'MarkerFaceColor', 'm');
  plot(F_2oct_high, Ganho_dB(F_2oct_high), 'mo', 'MarkerFaceColor', 'm');

  legend('Curva Passa-Faixa', 'Centro', 'F_{corte}', 'F_{corte}', '-1 Oitava', '+1 Oitava', '-2 Oitavas', '+2 Oitavas');
  axis([10 100000 min(plot_dB) max(plot_dB)+3]);
end

% ====== SCRIPT PRINCIPAL ======

Ic       = 0.002;
B        = 260;
Vcc      = 10;
Vt       = 0.026;
Fc_low   = 500;
Fc_high  = 6000;
Rl       = 100000;

printf("==== Vcc = %.2f V | Ic = %.2f mA | Hfe = %d ====\n", Vcc, Ic*1e3, B);
printf("===  Vt = %.2f mV |  FL = %d Hz  | FH = %d Hz ==\n", Vt*1e3, Fc_low, Fc_high);

% 1. Chama as funções para calcular
[R1, R2, Rc, Re] = analiseDC(Vcc, Ic, B);
[C1, C2, C3, Zin, Zout, A] = analiseAC(Vcc, Ic, B, Vt, Fc_low, Fc_high, R1, R2, Re, Rc, Rl);

% 2. CRIAÇÃO DO GRÁFICO DA RETA DE CARGA
figure(2);

% Pontos extremos da reta (Corte e Saturação)
Vce_cutoff = Vcc;
Ic_sat = Vcc / (Rc + Re);

% Ponto Quiescente (Q)
Vce_Q = Vcc - Ic*(Rc + Re);
Ic_Q = Ic;

% Plotagem Reta de Carga
plot([0, Vce_cutoff], [Ic_sat*1000, 0], 'b-', 'LineWidth', 2);
hold on; grid on;
% Plotagem Ponto Q
plot(Vce_Q, Ic_Q*1000, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');

title('Reta de Carga DC');
xlabel('V_{CE} (V)');
ylabel('I_C (mA)');
legend('Reta de Carga', 'Ponto Q');

% Adiciona o texto ao lado do Ponto Q
texto_Q = sprintf('  Q (%.2f V, %.2f mA)', Vce_Q, Ic_Q*1000);
text(Vce_Q, Ic_Q*1000 + 0.05, texto_Q, 'FontSize', 10, 'Color', 'r');

% Ajusta eixos para não colar na borda
axis([0 Vcc+1 0 (Ic_sat*1000)+0.5]);
