% Valores de entrada
Vcc = 10;      % Tensão Vcc em Volts
Ic = 2e-3;     % Corrente Ic em Amperes (2mA)
beta = 260;    % Ganho Beta (hFE)

% --- Passos do Cálculo ---

% 1. Cálculo de Ve
Ve = 0.1 * Vcc;

% 2. Cálculo de Re (Considerando Ie ~= Ic)
Re = Ve / Ic;

% 3. Cálculo de Vce e Rc
Vce = 0.5 * Vcc;
Rc = (Vcc - Vce - Ve) / Ic;

% 4. Cálculo de Rth
Rth = 0.1 * (beta + 1) * Re;

% 5. Cálculo de Ib
Ib = Ic / beta;

% 6. Cálculo de Vb (Considerando Vbe = 0.7V)
Vbe = 0.7;
Vb = Ve + Vbe;

% 7. Cálculo de Vth
Vth = Vb + (Rth * Ib);

% 8. Cálculo de R1
R1 = (Rth * Vcc) / Vth;

% 9. Cálculo de R2
R2 = (Rth * Vcc) / (Vcc - Vth);

% --- Exibição dos Resultados ---
printf("=== Resultados do Dimensionamento ===\n");
printf("Vcc = %.2f V | Ic = %.2f mA | Beta = %d\n\n", Vcc, Ic*1000, beta);
printf("1. Ve  = %.2f V\n", Ve);
printf("2. Re  = %.2f Ohms\n", Re);
printf("3. Vce = %.2f V\n", Vce);
printf("   Rc  = %.2f Ohms\n", Rc);
printf("4. Rth = %.2f Ohms\n", Rth);
printf("5. Ib  = %e A (%.2f uA)\n", Ib, Ib*1e6);
printf("6. Vb  = %.2f V\n", Vb);
printf("7. Vth = %.2f V\n", Vth);
printf("8. R1  = %.2f Ohms\n", R1);
printf("9. R2  = %.2f Ohms\n", R2);
