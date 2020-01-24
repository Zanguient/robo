//+------------------------------------------------------------------+
//|                                                 ROBOLAB_COHEN.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link "https://www.mql5.com"
#property version "1.00"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>

CTrade operacao;

enum tipoEntrada // Enumeração de constantes nomeadas
{
    Max = 1,   // Maxima do Candle
    Close = 2, // Fechamento Candle
};

enum sinalIndicador // Enumeração de constantes nomeadas
{
    Crescente = 1,   // Sinal Crescente
    Decrescente = 2, // Sinal Decrescente
    Neutro = 3,      // Desconsidera
};

//+------------------------------------------------------------------+
//| PARAMETROS ENTRADA                                               |
//+------------------------------------------------------------------+

input string cabecario1;      // ====== ALVO/LOSS - NORMAL ========
input int qtdContratos = 1;   // Quantidade de contratos
input double gain = 1000;     // GAIN
input double loss = 250;      // LOSS - Distancia maximo Topo/Fundo
input double breakEven = 250; // BreakEven
input string cabecario2;      // ====== ALVO/LOSS - FIBO ========== // identificar fundo e topo com zigzag

input string cabecario3; // ====== ALVO/LOSS - PROPORCAO ===== // identificar fundo e topo com zigzag

input string cabecario4;                      // ====== SINAL ENTRADA =============
input tipoEntrada tipodaentrada = 1;          // Tipo Entrada
input double margemEntrada = 50;              // Margem de Entrada
input ENUM_TIMEFRAMES tempoOrdem = PERIOD_M5; // Tempo Expiracao Ordem

input string cabecario5;            // ====== STOP MOVEL ================
input double valorAtivacaoSm = 250; // Valor para Ativacao

input string cabecario6;      // ====== STOP MOVEL - ATR ==========
input bool usarSmAtr = false; // Usar Indicador

input string cabecario7;     // ====== STOP MOVEL - CANDLE =======
input bool usarSmCd = false; // Usar Indicador
input double margemSmCandle = 50; // Usar Indicador

input string cabecario8;     // ====== STOP MOVEL - HILO =========
input bool usarSmHi = false; // Usar Indicador

input string cabecario9;     // ====== STOP MOVEL - MEDIA ========
input bool usarSmMe = false; // Usar Indicador
input int mediaSm = 9;       //Media Utilizada

input string cabecario10;      // ====== STOP MOVEL - PONTOS =======
input bool usarSmPo = false;   // Usar Indicador
input int diferencaLoss = 100; // Valor Loss Movel x Preco Fechamento

input string cabecario11;     // ====== STOP MOVEL - SAR ========== // verificar se utilizar SAR[1] ou sar[0]
input bool usarSmSar = false; // Usar Indicador
input double sarPasso = 0.02; // Passo
input double sarMaximo = 0.2; // Maximo

input string cabecario12;          // ====== INDICADORES - ATR ========
input bool usarAtr = false;        // Usar Indicador
input sinalIndicador sinalAtr = 3; // Sinal Indicador
input double fatorAtr = 0.7;       // Fator Multiplicacao`
input int periodoAtr = 14;         // Periodo

input string cabecario13;              // ====== INDICADORES - IFR ========
input bool usarIfr = false;            // Usar Indicador
input sinalIndicador sinalIfr = 3;     // Sinal Indicador
input double inicioFaixaCompraIfr = 0; // Inicio da Faixa Compra
input double fimFaixaCompraIfr = 100;  // Fim da Faixa Compra
input double inicioFaixaVendaIfr = 0;  // Inicio da Faixa Venda
input double fimFaixaVendaIfr = 100;   // Fim da Faixa Venda

input string cabecario14;               // ====== INDICADORES - MACD =======
input bool usarMacd = false;            // Usar Indicador
input sinalIndicador sinalMacd = 3;     // Sinal Indicador
input double inicioFaixaCompraMacd = 0; // Inicio da Faixa Compra
input double fimFaixaCompraMacd = 100;  // Fim da Faixa Compra
input double inicioFaixaVendaMacd = 0;  // Inicio da Faixa Venda
input double fimFaixaVendaMacd = 100;   // Fim da Faixa Venda

input string cabecario15;          // ====== INDICADORES - OBV ========
input bool usarObv = false;        // Usar Indicador
input sinalIndicador sinalObv = 3; // Sinal Indicador

input string cabecario20;          // ====== INDICADORES - Stoch ========
input bool usarStoch = false;        // Usar Indicador

input string cabecario21;          // ====== INDICADORES - RSI ========
input bool usarRsi = false;        // Usar Indicador

input string cabecario22;          // ====== INDICADORES - VWAP ========
input bool usarVwap = false;        // Usar Indicador
input double distancia = 250;      // Usar Distancia


input string cabecario18;          // ====== INDICADORES - VOLUME ========
input bool usarVolume = false;        // Usar Indicador
input double volumeMinimo = 15000;  // Fim da Faixa Compra

input string cabecario16;             // ====== HORARIOS =================
input string horarioAbrMin = "09:00"; // Abertura MIN
input string horarioAbrMax = "17:00"; // Abertura MAX
input string horarioFecMax = "17:30"; // Fechamento MAX
input string cabecario17;             // ====== METAS =====================
input double metaGainDi = 300;        // Ganho Max Diario ($)
input double metaLossDi = -300;       // Perda Max Diario ($)

//+------------------------------------------------------------------+
//| VARIAVIES                                                        |
//+------------------------------------------------------------------+

int mCohen;
int mSmAtr;
int mSmHilo;
int mSmMedia;
int mSmSar;
int mAtr;
int mIfr;
int mMacd;
int mObv;
int mZigZag;
int mVolume;
int mStoch;
int mRSI;
int mVwap;

double cohenArray4[];
double cohenArray5[];

double MediaZigZagHigh[];
double MediaZigZagLow[];

double topo[4];
double fundo[4];

double smAtrArray[];
double smHiloArray[];
double smMediaArray[];
double smSarArray[];
double atrArray[];
double ifrArray[];
double macdArray[];
double obvArray[];
double volumeArray[];
double RSIArray[];
double VwapArray[];
double smHiloCorArray[];

bool breakEvenExecutado = false;

double mStochArray[];

MqlRates BarData[1];

bool ordemAberta = false;
bool mudouCandle = false;

double PrecoFechamentoPenultimoCandle = 1;

int OnInit()
{
    //---
    mCohen = iCustom(Symbol(), Period(), "Cohen", 30);
    mZigZag = iCustom(Symbol(), Period(), "ZigZag", 12, 5, 3);
 
    //mZigZag = iCustom(Symbol(), Period(), "ZigZag", 12, 5, 3);
    //hilo = iCustom(Symbol(), Period(), "HILO");
    //rsi = iRSI(Symbol(), Period(), 14, PRICE_CLOSE);
    //vwap = iCustom(Symbol(), Period(), "VWAP");    

    if (usarAtr)
        mAtr = iCustom(_Symbol, _Period, "ATR", periodoAtr);
    if (usarIfr)
        mIfr = 0;
    if (usarMacd)
        mMacd = iMACD(_Symbol, _Period, 12, 26, 9, PRICE_CLOSE);
    if (usarObv)
        mObv = iCustom(_Symbol, _Period, "OBV", VOLUME_TICK);
    if (usarSmAtr)
        mSmAtr = iCustom(_Symbol, _Period, "ATR", 14);
    if (usarSmHi)
        mSmHilo = iCustom(_Symbol, _Period, "HILOE", 13,MODE_EMA,-1);
    if (usarSmMe)
        mSmMedia = iMA(_Symbol, _Period, mediaSm, 0, MODE_EMA, PRICE_CLOSE);
    if (usarSmSar)
        mSmSar = iSAR(_Symbol, _Period, sarPasso, sarMaximo);
        
        if (usarVolume)
        mVolume = iVolumes(_Symbol, _Period, VOLUME_TICK);    
         if (usarStoch)
         mStoch = iStochastic(Symbol(), Period(), 5, 3, 3, MODE_SMA, STO_LOWHIGH);
         
         if (usarRsi)
         mRSI = iRSI(Symbol(), Period(), 14, PRICE_CLOSE);
         
         if (usarVwap)
        mVwap = iCustom(_Symbol, _Period, "VWAP");

    //---
    return (INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    //---
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{

    CopyRates(_Symbol, _Period, 1, 1, BarData);

    mudouCandle = VerificarMudouCandle();

    if (mudouCandle)
    {
        ordemAberta = OrdemAberta(_Symbol);

        if (ordemAberta) horarioFecharPosicaoIndice(horarioFecMax, SymbolInfoDouble(_Symbol, SYMBOL_LAST), _Symbol, qtdContratos);

        if (ordemAberta)
        {
            if (usarSmAtr)
                StopGainMovelAtr();
            if (usarSmPo)
                StopGainMovelPontos();
            if (usarSmCd)
                StopGainMovelCandle();
            if (usarSmMe)
                StopGainMovelMedia();
            if (usarSmHi)
                StopGainMovelHilo();
            if (usarSmSar)
                StopGainMovelSar();
        }
        
        // implementar stop para candle gigante = 800
        

        ArraySetAsSeries(cohenArray4, true);
        ArraySetAsSeries(cohenArray5, true);

        CopyBuffer(mCohen, 3, 0, 3, cohenArray4);
        CopyBuffer(mCohen, 4, 0, 3, cohenArray5);
        

        if (usarAtr)
        {
            ArraySetAsSeries(atrArray, true);
            CopyBuffer(mAtr, 0, 0, 3, atrArray);
        }
        
        if (usarStoch)
        {
            ArraySetAsSeries(mStochArray, true);
            CopyBuffer(mStoch, 1, 0, 3, mStochArray);
        }

        if (usarIfr)
        {
            ArraySetAsSeries(ifrArray, true);
            CopyBuffer(mIfr, 0, 0, 3, ifrArray);
        }

        if (usarMacd)
        {
            ArraySetAsSeries(macdArray, true);
            CopyBuffer(mMacd, 0, 0, 3, macdArray);
        }

        if (usarObv)
        {
            ArraySetAsSeries(obvArray, true);
            CopyBuffer(mObv, 0, 0, 3, obvArray);
        }

        if (usarSmAtr)
        {
            ArraySetAsSeries(smAtrArray, true);
            CopyBuffer(mSmAtr, 0, 0, 3, smAtrArray);
        }

        if (usarSmHi)
        {
            ArraySetAsSeries(smHiloArray, true);
            ArraySetAsSeries(smHiloCorArray, true);
            CopyBuffer(mSmHilo, 0, 0, 3, smHiloArray);
             CopyBuffer(mSmHilo, 2, 0, 3, smHiloCorArray);
          
        }

        if (usarSmMe)
        {
            ArraySetAsSeries(smMediaArray, true);
            CopyBuffer(mSmMedia, 0, 0, 3, smMediaArray);
        }

        if (usarSmSar)
        {
            ArraySetAsSeries(smSarArray, true);
            CopyBuffer(mSmSar, 0, 0, 3, smSarArray);
        }
        
        if (usarVolume)
        {
            ArraySetAsSeries(volumeArray, true);
            CopyBuffer(mVolume, 0, 0, 3, volumeArray);
        }
        
        if (usarRsi)
        {
            ArraySetAsSeries(RSIArray, true);
            CopyBuffer(mRSI, 0, 0, 3, RSIArray);
        }
        
         if (usarVwap)
        {
            ArraySetAsSeries(VwapArray, true);
            CopyBuffer(mVwap, 0, 0, 3, VwapArray);
        }
        
        if (!breakEvenExecutado)  breakevenExecutar();

        if (horaOperar(horarioAbrMax) && cohenArray4[1] == 1 
        && (!usarAtr || (atrArray[1] * fatorAtr < BarData[0].close - BarData[0].open)) 
        && (!usarAtr || (atrArray[1] > atrArray[2] && sinalAtr == 1) || (atrArray[1] < atrArray[2]  && sinalAtr == 2) || sinalAtr == 3) 
        && (!usarObv || (obvArray[0] > obvArray[1] && sinalObv == 1) || (obvArray[0] < obvArray[1] && sinalObv == 2) || sinalObv == 3) 
        && (!usarMacd || (macdArray[1] > macdArray[2] && sinalMacd == 1) || (macdArray[1] < macdArray[2] && sinalMacd == 2) || sinalMacd == 3) 
        && (!usarVolume || (volumeArray[1] > volumeMinimo)) 
        && (!usarStoch || (mStochArray[0] < 80))
        && (!usarRsi || (RSIArray[1] < 70))
        && !ordemAberta
        && !funcao_verifica_meta_ou_perda_atingida("Meta", metaLossDi, metaGainDi, true)
        && (!usarVwap || (VwapArray[1] - BarData[0].close > distancia ))  
        )
        {
            // ver ser a variacao 0 -> 1 ATR e OBV
            datetime expiration = TimeTradeServer() + PeriodSeconds(tempoOrdem);
            double precoReferencia = 0;
              double lossref = 0;

            buscarSinal();
            fecharTodasOrdensPendentes();

            if (tipodaentrada == 1)
                precoReferencia = BarData[0].high + margemEntrada;
            else
                precoReferencia = BarData[0].close + margemEntrada;
                
                  //if (precoReferencia - loss < fundo[0] ) lossref = fundo[0];
                //else 
                lossref = precoReferencia - loss;

            //if (precoReferencia - loss < fundo[0])
                operacao.BuyStop(qtdContratos, precoReferencia, _Symbol, lossref, precoReferencia + gain, ORDER_TIME_SPECIFIED, expiration);
                breakEvenExecutado = false;

            //operacao.Buy(1, _Symbol, precoReferencia, precoReferencia - loss, precoReferencia + gain);
        }

        else if (horaOperar(horarioAbrMax) && cohenArray5[1] == 1 
        && (!usarAtr || (atrArray[1] * fatorAtr < BarData[0].open - BarData[0].close)) && (!usarAtr || (atrArray[1] > atrArray[2] && sinalAtr == 1) || (atrArray[1] < atrArray[2] && sinalAtr == 2) || sinalAtr == 3) 
        && (!usarObv || (obvArray[0] > obvArray[1] && sinalObv == 1) || (obvArray[0] < obvArray[1] && sinalObv == 2) || sinalObv == 3) 
        && (!usarMacd || (macdArray[1] > macdArray[2] && sinalMacd == 1) || (macdArray[1] < macdArray[2] && sinalMacd == 2) || sinalMacd == 3) 
        && !ordemAberta
        && (!usarVolume || (volumeArray[1] > volumeMinimo) )
        && (!usarStoch || (mStochArray[0] > 20))
        && (!usarRsi || (RSIArray[1] > 30))
        && (!usarVwap || (BarData[0].close - VwapArray[1] > distancia ))
        && !funcao_verifica_meta_ou_perda_atingida("Meta", metaLossDi, metaGainDi, true)        
        )
        {

            // ver ser a variacao 0 -> 1 ATR e OBV
            datetime expiration = TimeTradeServer() + PeriodSeconds(tempoOrdem);

            double precoReferencia = 0;
            double lossref = 0;

            buscarSinal();
            fecharTodasOrdensPendentes();

            if (tipodaentrada == 1)
                precoReferencia = BarData[0].low - margemEntrada;
            else
                precoReferencia = BarData[0].close - margemEntrada;
                
                //if (precoReferencia + loss > topo[0] ) lossref = topo[0];
                //else 
                lossref = precoReferencia + loss;

            //if (precoReferencia + loss > topo[0])
                operacao.SellStop(qtdContratos, precoReferencia, _Symbol, lossref, precoReferencia - gain, ORDER_TIME_SPECIFIED, expiration);
                breakEvenExecutado = false;

            //operacao.Sell(1, _Symbol, precoReferencia, precoReferencia + loss, precoReferencia - gain);
        }
    }
    //---
}
//+------------------------------------------------------------------+
bool VerificarMudouCandle()
{
    if (BarData[0].close != PrecoFechamentoPenultimoCandle)
    {
        PrecoFechamentoPenultimoCandle = BarData[0].close;
        return true;
    }

    else
        return false;
}

bool horaOperar(string inicioPrimeiroPeriodo)
{
    datetime horaCorrente = TimeCurrent();

    string horaCorrenteStr = TimeToString(horaCorrente, TIME_MINUTES);

    horaCorrente = StringToTime("2019.01.01 " + horaCorrenteStr);

    if (StringToTime("2019.01.01 " + horaCorrenteStr) <= StringToTime("2019.01.01 " + inicioPrimeiroPeriodo))
    {
        return true;
    }
    else
    {
        return false;
    }
}

bool OrdemAberta(string ativo)
{
    if (PositionSelect(ativo) == true)
        return true;
    else
        return false;
}

void StopGainMovelPontos()
{

    ulong PositionTicket = PositionGetInteger(POSITION_TICKET);
    double StopLossCorrente = PositionGetDouble(POSITION_SL);
    double GainCorrente = PositionGetDouble(POSITION_TP);
    double PrecoAberturaPosicao = PositionGetDouble(POSITION_PRICE_OPEN);

    if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
    {

        if (BarData[0].close - PrecoAberturaPosicao > valorAtivacaoSm)
        {

            if (BarData[0].close - StopLossCorrente > diferencaLoss)
            {
                double precoAtual = SymbolInfoDouble(_Symbol, SYMBOL_LAST);
                operacao.PositionModify(PositionTicket, precoAtual - diferencaLoss, precoAtual + gain);
            }
        }
    }
    else
    {
        if (PrecoAberturaPosicao - BarData[0].close > valorAtivacaoSm)
        {
            if (StopLossCorrente - BarData[0].close > diferencaLoss)
            {
                double precoAtual = SymbolInfoDouble(_Symbol, SYMBOL_LAST);
                operacao.PositionModify(PositionTicket, precoAtual + diferencaLoss, precoAtual - gain);
            }
        }
    }
}

void StopGainMovelCandle()
{

    ulong PositionTicket = PositionGetInteger(POSITION_TICKET);
    double StopLossCorrente = PositionGetDouble(POSITION_SL);
    double GainCorrente = PositionGetDouble(POSITION_TP);
    double PrecoAberturaPosicao = PositionGetDouble(POSITION_PRICE_OPEN);

    if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
    {

        if (BarData[0].close - PrecoAberturaPosicao > valorAtivacaoSm && BarData[0].low - margemSmCandle > PrecoAberturaPosicao)
        {
            double precoAtual = SymbolInfoDouble(_Symbol, SYMBOL_LAST);
            operacao.PositionModify(PositionTicket, BarData[0].low - margemSmCandle, precoAtual + gain);
        }
    }
    else
    {
        if (PrecoAberturaPosicao - BarData[0].close > valorAtivacaoSm && BarData[0].high + margemSmCandle < PrecoAberturaPosicao )
        {
            double precoAtual = SymbolInfoDouble(_Symbol, SYMBOL_LAST);
            operacao.PositionModify(PositionTicket, BarData[0].high + margemSmCandle, precoAtual - gain);
        }
    }
}

void StopGainMovelMedia()
{

    ulong PositionTicket = PositionGetInteger(POSITION_TICKET);
    double StopLossCorrente = PositionGetDouble(POSITION_SL);
    double GainCorrente = PositionGetDouble(POSITION_TP);
    double PrecoAberturaPosicao = PositionGetDouble(POSITION_PRICE_OPEN);

    if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
    {

        if (BarData[0].close - PrecoAberturaPosicao > valorAtivacaoSm)
        {

            double precoAtual = SymbolInfoDouble(_Symbol, SYMBOL_LAST);
            if (smMediaArray[1] > precoAtual)
            {
                int loss = 0;
                int multiplicador = smMediaArray[1] / 5;
                loss = multiplicador * 5;
                operacao.PositionModify(PositionTicket, loss, precoAtual + gain);
            }
        }
    }
    else
    {
        if (PrecoAberturaPosicao - BarData[0].close > valorAtivacaoSm)
        {

            double precoAtual = SymbolInfoDouble(_Symbol, SYMBOL_LAST);
            if (smMediaArray[1] < precoAtual)
            {
                int loss = 0;
                int multiplicador = smMediaArray[1] / 5;
                loss = multiplicador * 5;
                operacao.PositionModify(PositionTicket, loss, precoAtual - gain);
            }
        }
    }
}

void StopGainMovelHilo()
{

    ulong PositionTicket = PositionGetInteger(POSITION_TICKET);
    double StopLossCorrente = PositionGetDouble(POSITION_SL);
    double GainCorrente = PositionGetDouble(POSITION_TP);
    double PrecoAberturaPosicao = PositionGetDouble(POSITION_PRICE_OPEN);

    if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
    {

        if (BarData[0].close - PrecoAberturaPosicao > valorAtivacaoSm)
        {
            double precoAtual = SymbolInfoDouble(_Symbol, SYMBOL_LAST);
            if (smHiloArray[1] < precoAtual && smHiloCorArray[1] == 0)
            {
                int loss = 0;
                int multiplicador = smHiloArray[1] / 5;
                loss = multiplicador * 5;
                operacao.PositionModify(PositionTicket, loss, precoAtual + gain);
            }
        }
    }
    else
    {
        if (PrecoAberturaPosicao - BarData[0].close > valorAtivacaoSm)
        {
            double precoAtual = SymbolInfoDouble(_Symbol, SYMBOL_LAST);
            if (smHiloArray[1] > precoAtual && smHiloCorArray[1] == 1)
            {
                int loss = 0;
                int multiplicador = smHiloArray[1] / 5;
                loss = multiplicador * 5;
                operacao.PositionModify(PositionTicket, loss, precoAtual - gain);
            }
        }
    }
}

void StopGainMovelSar()
{

    ulong PositionTicket = PositionGetInteger(POSITION_TICKET);
    double StopLossCorrente = PositionGetDouble(POSITION_SL);
    double GainCorrente = PositionGetDouble(POSITION_TP);
    double PrecoAberturaPosicao = PositionGetDouble(POSITION_PRICE_OPEN);

    if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
    {

        if (BarData[0].close - PrecoAberturaPosicao > valorAtivacaoSm)
        {

            double precoAtual = SymbolInfoDouble(_Symbol, SYMBOL_LAST);
            if (smSarArray[1] > precoAtual)
            {
                int loss = 0;
                int multiplicador = smSarArray[1] / 5;
                loss = multiplicador * 5;
                operacao.PositionModify(PositionTicket, loss, precoAtual + gain);
            }
        }
    }
    else
    {
        if (PrecoAberturaPosicao - BarData[0].close > valorAtivacaoSm)
        {

            double precoAtual = SymbolInfoDouble(_Symbol, SYMBOL_LAST);
            if (smSarArray[1] < precoAtual)
            {
                int loss = 0;
                int multiplicador = smSarArray[1] / 5;
                loss = multiplicador * 5;
                operacao.PositionModify(PositionTicket, loss, precoAtual - gain);
            }
        }
    }
}

void StopGainMovelAtr()
{

    ulong PositionTicket = PositionGetInteger(POSITION_TICKET);
    double StopLossCorrente = PositionGetDouble(POSITION_SL);
    double GainCorrente = PositionGetDouble(POSITION_TP);
    double PrecoAberturaPosicao = PositionGetDouble(POSITION_PRICE_OPEN);

    if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
    {

        if (BarData[0].close - PrecoAberturaPosicao > valorAtivacaoSm)
        {
            double precoAtual = SymbolInfoDouble(_Symbol, SYMBOL_LAST);
            operacao.PositionModify(PositionTicket, smAtrArray[1], precoAtual + gain);
        }
    }
    else
    {
        if (PrecoAberturaPosicao - BarData[0].close > valorAtivacaoSm)
        {
            double precoAtual = SymbolInfoDouble(_Symbol, SYMBOL_LAST);
            operacao.PositionModify(PositionTicket, smAtrArray[1], precoAtual - gain);
        }
    }
}

void fecharTodasOrdensPendentes()
{

    MqlTradeRequest request = {0};
    MqlTradeResult result = {0};

    ulong order_ticket = OrderGetTicket(0);

    ZeroMemory(request);
    ZeroMemory(result);
    //--- setting the operation parameters
    request.action = TRADE_ACTION_REMOVE;
    request.order = order_ticket;

    if (!OrderSend(request, result))
        PrintFormat("OrderSend error %d", GetLastError());
    PrintFormat("retcode=%u  deal=%I64u  order=%I64u", result.retcode, result.deal, result.order);
}

void buscarSinal()
{
    ArraySetAsSeries(MediaZigZagHigh, true);
    ArraySetAsSeries(MediaZigZagLow, true);

    CopyBuffer(mZigZag, 1, 0, 100, MediaZigZagHigh);
    CopyBuffer(mZigZag, 2, 0, 100, MediaZigZagLow);

    int contadorTopo = 0;
    int contadorFundo = 0;

    int x;

    for (x = 0; x < 99; x++)
    {

        //printf("H:" + MediaZigZagHigh[x]);
        // printf("L:" + MediaZigZagLow[x]);

        if (contadorTopo < 4)
        {
            if ((MediaZigZagHigh[x] != 0.0))
            {
                //printf("H:" + MediaZigZagHigh[x]);
                topo[contadorTopo] = MediaZigZagHigh[x];
                contadorTopo++;
            }
        }

        if (contadorFundo < 4)
        {
            if ((MediaZigZagLow[x] != 0.0))
            {
                //printf("H:" + MediaZigZagLow[x]);
                fundo[contadorFundo] = MediaZigZagLow[x];
                contadorFundo++;
            }
        }
    }
}

bool funcao_verifica_meta_ou_perda_atingida(string tmpOrigem, double tmpValorMaximoPerda, double tmpValor_Maximo_Ganho, bool tmp_placar)
{
    //tmpOrigem = comentario de qual local EA foi chamado a função
    //tmpValorMaximoPerda = valor máximo desejado como perda máxima
    //tmpValor_Maximo_Ganho = valor estipulado de meta do  dia
    //tmp_placar = true exibe no comment o resultado das negociações do dia

    Print("Pesquisa funcao_verifica_meta_ou_perda_atingida (" + tmpOrigem + ")");
    string tmp_x;
    double tmp_resultado_financeiro_dia;
    int tmp_contador;
    MqlDateTime tmp_data_b;

    TimeCurrent(tmp_data_b);
    tmp_resultado_financeiro_dia = 0;
    tmp_x = string(tmp_data_b.year) + "." + string(tmp_data_b.mon) + "." + string(tmp_data_b.day) + " 00:00:01";

    HistorySelect(StringToTime(tmp_x), TimeCurrent());
    int tmp_total = HistoryDealsTotal();
    ulong tmp_ticket = 0;
    double tmp_price;
    double tmp_profit;
    datetime tmp_time;
    string tmp_symboll;
    long tmp_typee;
    long tmp_entry;

    //--- para todos os negócios 
    for (tmp_contador = 0; tmp_contador < tmp_total; tmp_contador++)
    {
        //--- tentar obter ticket negócios 
        if ((tmp_ticket = HistoryDealGetTicket(tmp_contador)) > 0)
        {
            //--- obter as propriedades negócios 
            tmp_price = HistoryDealGetDouble(tmp_ticket, DEAL_PRICE);
            tmp_time = (datetime)HistoryDealGetInteger(tmp_ticket, DEAL_TIME);
            tmp_symboll = HistoryDealGetString(tmp_ticket, DEAL_SYMBOL);
            tmp_typee = HistoryDealGetInteger(tmp_ticket, DEAL_TYPE);
            tmp_entry = HistoryDealGetInteger(tmp_ticket, DEAL_ENTRY);
            tmp_profit = HistoryDealGetDouble(tmp_ticket, DEAL_PROFIT);
            //--- apenas para o símbolo atual 
            if (tmp_symboll == _Symbol) tmp_resultado_financeiro_dia = tmp_resultado_financeiro_dia + tmp_profit;

        }
    }

    if (tmp_resultado_financeiro_dia == 0)
    {
        if (tmp_placar = true) Comment("Placar  0x0");
        return (false); //sem ordens no dia
    }
    else
    {
        if ((tmp_resultado_financeiro_dia > 0) && (tmp_resultado_financeiro_dia != 0))
        {
            if (tmp_placar = true) Comment("Lucro R$" + DoubleToString(NormalizeDouble(tmp_resultado_financeiro_dia, 2), 2));
        }
        else
        {
            if (tmp_placar = true) Comment("Prejuizo R$" + DoubleToString(NormalizeDouble(tmp_resultado_financeiro_dia, 2), 2));
        }

        if (tmp_resultado_financeiro_dia < tmpValorMaximoPerda)
        {
            Print("Perda máxima alcançada.");
            return (true);
        }
        else
        {
            if (tmp_resultado_financeiro_dia > tmpValor_Maximo_Ganho)
            {
                Print("Meta Batida.");
                return (true);
            }
        }
    }
    return (false);
}


bool horarioFecharPosicaoIndice(string horarioMaximo, float precoAtual, string ativo, int tamanhoLote)
{


    ulong PositionTicket = PositionGetInteger(POSITION_TICKET);
    double StopLossCorrente = PositionGetDouble(POSITION_SL);
    double GainCorrente = PositionGetDouble(POSITION_TP);
    double PrecoAberturaPosicao = PositionGetDouble(POSITION_PRICE_OPEN);

    datetime horaCorrente = TimeCurrent();

    string horaCorrenteStr = TimeToString(horaCorrente, TIME_MINUTES);

    horaCorrente = StringToTime("2020.01.01 " + horaCorrenteStr);

    if (StringToTime("2020.01.01 " + horaCorrenteStr) > StringToTime("2020.01.01 " + horarioMaximo))
    {
        if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
          //  operacao.PositionModify(PositionTicket, precoAtual + 20, precoAtual - 20);
        operacao.Sell(tamanhoLote, ativo, precoAtual);

        else
            operacao.Buy(tamanhoLote, ativo, precoAtual);
          //  operacao.PositionModify(PositionTicket, precoAtual - 20, precoAtual + 20);

        return true;

    }
    else return false;

}

void breakevenExecutar()
{
    
    ulong PositionTicket = PositionGetInteger(POSITION_TICKET);
    double StopLossCorrente = PositionGetDouble(POSITION_SL);
    double GainCorrente = PositionGetDouble(POSITION_TP);
    double PrecoAberturaPosicao = PositionGetDouble(POSITION_PRICE_OPEN);

    if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
    {

        if (BarData[0].close - PrecoAberturaPosicao > breakEven)
        {
            double precoAtual = SymbolInfoDouble(_Symbol, SYMBOL_LAST);
            operacao.PositionModify(PositionTicket, PrecoAberturaPosicao, precoAtual + gain);
            breakEvenExecutado = true;
        }
    }
    else
    {
        if (PrecoAberturaPosicao - BarData[0].close > breakEven)
        {
            double precoAtual = SymbolInfoDouble(_Symbol, SYMBOL_LAST);
            operacao.PositionModify(PositionTicket, PrecoAberturaPosicao, precoAtual - gain);
            breakEvenExecutado = true;
        }
    }
}