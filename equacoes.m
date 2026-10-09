1;
% Dados iniciais (Arbitrários):
% Vcc, Ic, Hfe
% Fc_low, Fc_high
%
% Elementos a definir:
% Impedancias (Zin, Zout)
% Ganho
% Resistências (Rc, Re, R1, R2) -> polarização
% Capacitores (C1, C2, C3) -> Passa banda e acoplamento

% Informações sobre o dispositivo da yamaha:
% https://audio-database.com/YAMAHA/speaker/ns-1000m.html -> frequencia de crossover (vulgo frequência de corte): 500 Hz, 6 kHz, 12dB/oct.
% Ou seja, os médios vão de 500 Hz até 6 kHz, caindo 12dB por oitava após a frequência de corte

% Ao polarizar um BJT deseja-se manter o ponto Q independente de parâmetros externos
% Para isso devemos minimizar o efeito de Bcc (Hfe) da seguinte forma: R2 <= 0.01*Bcc*Re
% Porém essa configuração deixa a impedância de entrada do circuito muito baixa
% Para resolver utilizamos: R2 <= 0.1*Bcc*Re
% Bcc é o menor valor possível do BJT


% Polarização do BJT, aproximando Ie = Ic;
function [R1, R2, Rc, Re] = analiseDC(Vcc, Ic, Hfe)
  Bcc = 110 % menor valor do beta do BJT
  % Tensões ao redor do BJT
  Vc = 0.5*Vcc;
  Ve = 0.1*Vcc;
  Vb = Ve + 0.7;
  % Calculo dos Resistores
  Rc = (Vcc-Vc-Ve)/Ic;
  Re = Ve/Ic;      % considerando Ie = Ic
  R2 = 0.1*Bcc*Re; % não sei se deixo assim ou se boto Hfe direto 
  R1 = ((R2*Vcc)/Vb) - R2;
  
  printf("\n=== RESULTADOS DC ===\n");
  printf("Ib: %.2e\n", Ic/Hfe);
  printf("Resistores:\n");
  printf("Rc: %.2f\n", Rc);
  printf("Re: %.2f\n", Re);
  printf("R1: %.2f\n", R1);
  printf("R2: %.2f\n", R2);
  printf("Tensões:\n");
  printf("Vc:  %.2e\n", Vc);
  printf("Ve:  %.2e\n", Ve);
  printf("Vb:  %.2e\n", Vb);
end

% Definição dos capacitores nas frequencias de corte 500 Hz e 6 kHz
% E analise das impedâncias e ganho
% Zin e Zout são funções
function [C1, C2, C3, Zin, Zout] = analiseAC(Vcc, Ic, Hfe, Vt, Fc_low, Fc_high, R1, R2, Re, Rc, Rl)
  paralelo = @(r1, r2) (r1*r2)/(r1+r2);
  Xc = @(C, f) 1/(2*pi*f*C);
  capacitor_corte = @(fc, r) 1/(2*pi*fc*r);
  % C1 é o passa faixa na entrada do BJT
  re = Vt/Ic;
  req = paralelo(paralelo(R1, R2), Hfe*(Re+re)) % paraleo das resistencias da entrada
  C1 = capacitor_corte(Fc_low, req);
  C2 = capacitor_corte(Fc_high, Rc); % apenas o Rc participa da conta para o passa baixa na saida
  C3 = capacitor_corte(0.1*Fc_low, Rl); % Capacitor de acoplamento, forma um passa baixa com o Rl

  printf("Xc(20)    = %d\n", Xc(C1, 20));
  printf("Xc(20000) = %d\n", Xc(C1, 20000));
  Zin  = @(f) (Xc(C1, f) + req);
  Zout = @(f) paralelo(Xc(C2, f), Rc);
  A    = @(f) -(Zout(f)/);

  fq   = [20 20000];
  figure
  grid on
  % fplot(Zin, fq, "b--");
  hold on
  % fplot(Zout, fq, "r--");
  hold on
  % fplot(A, fq, "bk--");
  legend("Zin", "Zout", "ganho")
end





Ic       = 0.002;
B        = 260;
Vcc      = 10;
Vt       = 0.026;
Fc_low   = 500;
Fc_high  = 6000;
Rl       = 100000;
printf("==== Vcc = %.2f V | Ic = %.2f mA | Hfe = %d ====\n", Vcc, Ic*1e3, B);
printf("===  Vt = %.2f mV |  FL = %d Hz  | FH = %d Hz ==\n", Vt*1e3, Fc_low, Fc_high);
[R1, R2, Rc, Re] = analiseDC(Vcc, Ic, B)
[C1, C2, C3, Zin, Zout] = analiseAC(Vcc, Ic, B, Vt, Fc_low, Fc_high, R1, R2, Re, Rc, Rl)
