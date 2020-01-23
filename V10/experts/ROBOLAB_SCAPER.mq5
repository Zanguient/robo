//+------------------------------------------------------------------+
//|                                               ROBOLAB_SCAPER.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

#include <Trade\Trade.mqh>

CTrade operacao;

input string cabecario1;      // ====== ALVO/LOSS - NORMAL ========
input int qtdContratos = 1;   // Quantidade de contratos
input double gain = 50;     // GAIN
input double loss = 300;      // LOSS - Distancia maximo Topo/Fundo
input double distancia = 70;      // Distancia VWAP
input double qtdCandles = 2;      // Quantidade Candles para Zerar

input string cabecario16;             // ====== HORARIOS =================
input string horarioAbrMin = "09:00"; // Abertura MIN
input string horarioAbrMax = "17:00"; // Abertura MAX
input string horarioFecMax = "17:30"; // Fechamento MAX

//+------------------------------------------------------------------+
//|                                 |
//+------------------------------------------------------------------+

int mVwap;
double VwapArray[];

bool mudouCandle = false;
bool ordemAberta = false;

int contador = 0;

double PrecoFechamentoPenultimoCandle = 1;

MqlRates BarData[1];


//+------------------------------------------------------------------+
//|                                 |
//+------------------------------------------------------------------+

int OnInit()
{
    //---

    //---

    mVwap = iCustom(_Symbol, _Period, "VWAP");

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
    //---


    CopyRates(_Symbol, _Period, 1, 1, BarData);

    mudouCandle = VerificarMudouCandle();



    if (mudouCandle)
    {

        ordemAberta = OrdemAberta(_Symbol);
        ArraySetAsSeries(VwapArray, true);
        CopyBuffer(mVwap, 0, 0, 3, VwapArray);

        if (!ordemAberta)
        {
            if ((VwapArray[1] - BarData[0].close < distancia && VwapArray[1] - BarData[0].close > 0) || (BarData[0].close - VwapArray[1] < distancia && BarData[0].close - VwapArray[1] > 0))
            {
                if (horaOperar(horarioAbrMax) && BarData[0].close > BarData[0].open)
                {
                    //SymbolInfoDouble(_Symbol, SYMBOL_LAST)
                    operacao.Sell(qtdContratos, _Symbol, SymbolInfoDouble(_Symbol, SYMBOL_LAST), SymbolInfoDouble(_Symbol, SYMBOL_LAST) + loss, SymbolInfoDouble(_Symbol, SYMBOL_LAST) - gain);
                    contador = 0;

                }
                else if (horaOperar(horarioAbrMax) && BarData[0].close < BarData[0].open)
                {
                    operacao.Buy(qtdContratos, _Symbol, SymbolInfoDouble(_Symbol, SYMBOL_LAST), SymbolInfoDouble(_Symbol, SYMBOL_LAST) - loss, SymbolInfoDouble(_Symbol, SYMBOL_LAST) + gain);
                    contador = 0;

                }
            }
        }
        else
        {


            ulong PositionTicket = PositionGetInteger(POSITION_TICKET);
            double StopLossCorrente = PositionGetDouble(POSITION_SL);
            double GainCorrente = PositionGetDouble(POSITION_TP);
            double PrecoAberturaPosicao = PositionGetDouble(POSITION_PRICE_OPEN);

            if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
            {


                if (BarData[0].close < BarData[0].open) contador++;
                if (contador == qtdCandles) operacao.Sell(qtdContratos, _Symbol, SymbolInfoDouble(_Symbol, SYMBOL_LAST), SymbolInfoDouble(_Symbol, SYMBOL_LAST) + loss, SymbolInfoDouble(_Symbol, SYMBOL_LAST) - gain);


            }
            else
            {


                if (BarData[0].close > BarData[0].open) contador++;
                if (contador == qtdCandles) operacao.Buy(qtdContratos, _Symbol, SymbolInfoDouble(_Symbol, SYMBOL_LAST), SymbolInfoDouble(_Symbol, SYMBOL_LAST) - loss, SymbolInfoDouble(_Symbol, SYMBOL_LAST) + gain);


            }

            //horaOperar(horarioAbrMax)



        }
    }
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


bool OrdemAberta(string ativo)
{
    if (PositionSelect(ativo) == true)
        return true;
    else
        return false;
}


bool horaOperar(string inicioPrimeiroPeriodo)
{
    datetime horaCorrente = TimeCurrent();

    string horaCorrenteStr = TimeToString(horaCorrente, TIME_MINUTES);

    horaCorrente = StringToTime("2020.01.01 " + horaCorrenteStr);

    if (StringToTime("2020.01.01 " + horaCorrenteStr) <= StringToTime("2020.01.01 " + inicioPrimeiroPeriodo))
    {
        return true;
    }
    else
    {
        return false;
    }
}