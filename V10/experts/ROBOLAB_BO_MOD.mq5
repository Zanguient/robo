//+------------------------------------------------------------------+
//|                                                 ROBOLAB_PHIL.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| VARIAVEIS                                   |
//+------------------------------------------------------------------+

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Indicadores.mqh>

Indicadores IndicadoresOperacao();

int media = 17;
int longa = 34;
int muitoLonga = 144;

int atr;
double atrArray[];

input int gain = 16; // Valor GAIN:
input int loss = 11; // Valor LOSS:
input double tamWeis  = 3; //Valor WEIS:

double mediaArray[];
double longaArray[];
double muitoLongaArray[];

MqlRates BarData[1];

double PrecoFechamentoPenultimoCandle = 1;

bool mudouCandle = false;
bool ordemAberta = false;

int weis;
double corArray[];
int weis2;
double corArray2[];
int weis3;
double corArray3[];

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    
    media = iMA(_Symbol, _Period, media, 0, MODE_EMA, PRICE_CLOSE);
    longa = iMA(_Symbol, _Period, longa, 0, MODE_EMA, PRICE_CLOSE);
    muitoLonga = iMA(_Symbol, _Period, muitoLonga, 0, MODE_EMA, PRICE_CLOSE);
    //atr = iCustom(Symbol(), Period(), "ATR",8);
    weis = iCustom(Symbol(), Period(), "Money",tamWeis);
    weis2 = iCustom(Symbol(), Period(), "Money",(tamWeis*2));
    weis3 = iCustom(Symbol(), Period(), "Money",(tamWeis*3));
        
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
    ordemAberta = IndicadoresOperacao.OrdemAberta(_Symbol);

    CopyRates(_Symbol, _Period, 1, 1, BarData);   

    mudouCandle = VerificarMudouCandle();    

    if (mudouCandle)
    {

        if (ordemAberta)
        {

            if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY && (BarData[0].close < longaArray[0]  ))
            {
                trade.Sell(1, _Symbol, SymbolInfoDouble(_Symbol, SYMBOL_BID));
            }
            else if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL && (BarData[0].close > longaArray[0] ))
            {
                trade.Buy(1, _Symbol, SymbolInfoDouble(_Symbol, SYMBOL_BID));
            }

        }
        
        double tamanhoCandle = 0;
        double sombraInf = 0;
        double sombraSup = 0;
        string sinalCandle = "";       
        

        if (BarData[0].close > BarData[0].open)
        {
            tamanhoCandle = BarData[0].close - BarData[0].open;
            sombraSup = BarData[0].high - BarData[0].close;
            sombraInf = BarData[0].open - BarData[0].low;
            sinalCandle = "C";
        }
        else
        {
            tamanhoCandle = BarData[0].open - BarData[0].close;
            sombraSup = BarData[0].high - BarData[0].open;
            sombraInf = BarData[0].close - BarData[0].low;
            sinalCandle = "V";
        }        
        

        IndicadoresOperacao.horarioFecharPosicaoIndice("17:30", SymbolInfoDouble(_Symbol, SYMBOL_BID), _Symbol, 1);
        
        ArraySetAsSeries(mediaArray, true);
        ArraySetAsSeries(longaArray, true);
        ArraySetAsSeries(muitoLongaArray, true);        
        //ArraySetAsSeries(atrArray, true);              
        ArraySetAsSeries(corArray, true);      
        ArraySetAsSeries(corArray2, true);     
        ArraySetAsSeries(corArray3, true);     
        
        CopyBuffer(media, 0, 0, 3, mediaArray);
        CopyBuffer(longa, 0, 0, 3, longaArray);
        CopyBuffer(muitoLonga, 0, 0, 3, muitoLongaArray); 
        //CopyBuffer(atr, 0, 0, 3, atrArray);        
        CopyBuffer(weis, 1, 0, 3, corArray);
        CopyBuffer(weis2, 1, 0, 3, corArray2);
        CopyBuffer(weis3, 1, 0, 3, corArray3);
        

        //COMPRA
        if ( IndicadoresOperacao.horaOperar("17:00")
        &&   !ordemAberta
        &&  (mediaArray[0] > longaArray[0] && longaArray[0] > muitoLongaArray[0] )           
        &&  (longaArray[2] >  mediaArray[2] && longaArray[1] <  mediaArray[1])
        //&&  horaOperarInicio("09:04")
        //&&  (atrArray[1] * 0.7) < tamanhoCandle
        && corArray[0] == 0
        && corArray2[0] == 0
        && corArray3[0] == 0
        )
        {            
            //trade.BuyStop(1,precoReferencia,_Symbol,precoReferencia - loss,precoReferencia + gain,ORDER_TIME_SPECIFIED,expiration);  
            //double precoReferencia = BarData[14].high + 1;
            //datetime expiration = TimeTradeServer() + PeriodSeconds(PERIOD_M5);
            trade.Buy(1, _Symbol, SymbolInfoDouble(_Symbol, SYMBOL_ASK), SymbolInfoDouble(_Symbol, SYMBOL_ASK) - loss, SymbolInfoDouble(_Symbol, SYMBOL_ASK) + gain);            

        }
        //VENDA
        if ( !ordemAberta       
        && IndicadoresOperacao.horaOperar("17:00")      
        && (mediaArray[0] < longaArray[0] && longaArray[0] < muitoLongaArray[0] )         
        &&  (longaArray[2] <  mediaArray[2] && longaArray[1] >  mediaArray[1])
        //&& horaOperarInicio("09:04")
        //&&  (atrArray[1] * 0.7) < tamanhoCandle
        && corArray[0] == 1
        && corArray2[0] == 1
        && corArray3[0] == 1
        )
        {
            //double precoReferencia = BarData[14].low;
            //datetime expiration = TimeTradeServer() + PeriodSeconds(PERIOD_M5);            
            // trade.SellStop(1,precoReferencia,_Symbol,precoReferencia + loss,precoReferencia - gain,ORDER_TIME_SPECIFIED,expiration);
            trade.Sell(1, _Symbol, SymbolInfoDouble(_Symbol, SYMBOL_BID), SymbolInfoDouble(_Symbol, SYMBOL_BID) + loss, SymbolInfoDouble(_Symbol, SYMBOL_BID) - gain);         
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

    else return false;
}

bool horaOperarInicio(string inicioPrimeiroPeriodo)
{
    datetime horaCorrente = TimeCurrent();

    string horaCorrenteStr = TimeToString(horaCorrente, TIME_MINUTES);

    horaCorrente = StringToTime("2019.01.01 " + horaCorrenteStr);

    if (StringToTime("2019.01.01 " + horaCorrenteStr) >= StringToTime("2019.01.01 " + inicioPrimeiroPeriodo))
    {
        return true;
    }
    else
    {
        return false;
    }

}