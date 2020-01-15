//+------------------------------------------------------------------+
//|                                                 ROBOLAB_DIDI.mq5 |
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

input double gain = 100; // GAIN
input double loss = 100; // LOSS
input string horario = "17:00"; // HORARIO MAX ABERTURA

int mCohen;

double cohenArray1[];
double cohenArray2[];
double cohenArray3[];
double cohenArray4[];
double cohenArray5[];
double cohenArray6[];
double cohenArray7[];
double cohenArray8[];

MqlRates BarData[1];

bool ordemAberta = false;

double PrecoFechamentoPenultimoCandle = 1;

int OnInit()
{
    //---      
    mCohen = iCustom(Symbol(), Period(), "Cohen", 30);
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

    if (VerificarMudouCandle())
    {
        //ordemAberta = OrdemAberta(_Symbol);
        /*if (ordemAberta)
            {

                sinal = buscarSinal();
                if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY &&  (fundo[2] >= BarData[0].close)  )
                {
                    operacao.Sell(1, _Symbol, SymbolInfoDouble(_Symbol, SYMBOL_BID));
                }
                else if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL &&  (    topo[2] <= BarData[0].close     ) )
                {
                    operacao.Buy(1, _Symbol, SymbolInfoDouble(_Symbol, SYMBOL_BID));
                }

            }*/

        ArraySetAsSeries(cohenArray1, true);
        ArraySetAsSeries(cohenArray2, true);
        ArraySetAsSeries(cohenArray3, true);
        ArraySetAsSeries(cohenArray4, true);
        ArraySetAsSeries(cohenArray5, true);
        ArraySetAsSeries(cohenArray6, true);
        ArraySetAsSeries(cohenArray7, true);
        ArraySetAsSeries(cohenArray8, true);

        CopyBuffer(mCohen, 0, 0, 3, cohenArray1);
        CopyBuffer(mCohen, 1, 0, 3, cohenArray2);
        CopyBuffer(mCohen, 2, 0, 3, cohenArray3);
        CopyBuffer(mCohen, 3, 0, 3, cohenArray4);
        CopyBuffer(mCohen, 4, 0, 3, cohenArray5);
        CopyBuffer(mCohen, 5, 0, 3, cohenArray6);
        CopyBuffer(mCohen, 6, 0, 3, cohenArray7);
        CopyBuffer(mCohen, 7, 0, 3, cohenArray8);

        if (horaOperar(horario))
        {
            // datetime expiration = TimeTradeServer() + PeriodSeconds(PERIOD_M30);        
            //double precoReferencia = BarData[0].high;
            // operacao.BuyStop(1,precoReferencia,_Symbol,precoReferencia - loss,precoReferencia + gain,ORDER_TIME_SPECIFIED,expiration); 
            double precoReferencia = SymbolInfoDouble(_Symbol, SYMBOL_LAST);
            //operacao.Buy(1, _Symbol, precoReferencia, precoReferencia - loss, precoReferencia + gain);
        }


        else if (horaOperar(horario))
        {
            // datetime expiration = TimeTradeServer() + PeriodSeconds(PERIOD_M30);        
            //double precoReferencia = BarData[0].low;
            double precoReferencia = SymbolInfoDouble(_Symbol, SYMBOL_LAST);
            // operacao.SellStop(1,precoReferencia,_Symbol,precoReferencia + loss,precoReferencia - gain,ORDER_TIME_SPECIFIED,expiration);
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

    else return false;
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
    if (PositionSelect(ativo) == true) return true;
    else return false;
}

