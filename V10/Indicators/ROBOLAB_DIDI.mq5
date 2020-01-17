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

input double diferencaTopoFundo = 100; // DIFERENCAO TOPO FUNDO

int mDidi;
int mCompra;
int mVenda;
int mZigZag;

double topoEntrada = 0;
double FundoEntrada = 0;


double topo[4];
double fundo[4];

int contadorTopo = 0;
int contadorFundo = 0;

bool mudouCandle = false;


double MediaCurtaArray[];
double MediaLongaArray[];
double MediaSuperArray[];

double MediaCompraArray[];
double MediaVendaArray[];

double MediaZigZag[];
double MediaZigZagHigh[];
double MediaZigZagLow[];

MqlRates BarData[1];

bool ordemAberta = false;

string sinal = "";


double PrecoFechamentoPenultimoCandle = 1;

int OnInit()
{
    //---


    mDidi = iCustom(Symbol(), Period(), "DidiIndex", PERIOD_CURRENT, MODE_SMA, PRICE_CLOSE, 0, 3, 8, 20);
    mCompra = iMA(_Symbol, _Period, 34, 0, MODE_EMA, PRICE_HIGH);
    mVenda = iMA(_Symbol, _Period, 34, 0, MODE_EMA, PRICE_LOW);
    mZigZag = iCustom(Symbol(), Period(), "ZigZag", 12, 5, 3);

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

    ordemAberta = OrdemAberta(_Symbol);
    
    
    
    
    
    
    


    if (VerificarMudouCandle())
    {
    
    
    if (ordemAberta)
        {
            
            sinal = buscarSinal();
            if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY &&  (fundo[2] >= BarData[0].low)  )
            {
                operacao.Sell(1, _Symbol, SymbolInfoDouble(_Symbol, SYMBOL_BID));
            }
            else if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL &&  (    topo[2] <= BarData[0].high     ) )
            {
                operacao.Buy(1, _Symbol, SymbolInfoDouble(_Symbol, SYMBOL_BID));
            }

        }
    
    
    

        ArraySetAsSeries(MediaCurtaArray, true);
        ArraySetAsSeries(MediaLongaArray, true);
        ArraySetAsSeries(MediaSuperArray, true);


        CopyBuffer(mDidi, 0, 0, 3, MediaCurtaArray);
        CopyBuffer(mDidi, 1, 0, 3, MediaSuperArray);
        CopyBuffer(mDidi, 2, 0, 3, MediaLongaArray);

        ArraySetAsSeries(MediaCurtaArray, true);
        ArraySetAsSeries(MediaCurtaArray, true);

        CopyBuffer(mCompra, 0, 0, 3, MediaCompraArray);
        CopyBuffer(mVenda, 0, 0, 3, MediaVendaArray);

        if (MediaCurtaArray[1] > MediaLongaArray[1]
        && MediaCurtaArray[2] < MediaLongaArray[2]
        && horaOperar(horario)
        && !ordemAberta){       
        
        
        if( buscarSinal() == "Compra"
        //&& SymbolInfoDouble(_Symbol, SYMBOL_LAST) > MediaCompraArray[0]
        //&& SymbolInfoDouble(_Symbol, SYMBOL_LAST) > MediaSuperArray[0]
        )
        {
        
        
            
            // datetime expiration = TimeTradeServer() + PeriodSeconds(PERIOD_M30);        
            //double precoReferencia = BarData[0].high;
            // operacao.BuyStop(1,precoReferencia,_Symbol,precoReferencia - loss,precoReferencia + gain,ORDER_TIME_SPECIFIED,expiration); 
            double precoReferencia = SymbolInfoDouble(_Symbol, SYMBOL_LAST);
            
            operacao.Buy(1, _Symbol, precoReferencia, precoReferencia - loss, precoReferencia + gain);
        }
        }

        else if (
        MediaCurtaArray[1] < MediaLongaArray[1]
        && MediaCurtaArray[2] > MediaLongaArray[2]
        && horaOperar(horario)
        && !ordemAberta){                
        
        if (buscarSinal() == "Venda"
        //&& SymbolInfoDouble(_Symbol, SYMBOL_LAST) < MediaVendaArray[0]
        //&&  SymbolInfoDouble(_Symbol, SYMBOL_LAST) < MediaSuperArray[0]
        )
        {
        
            
            // datetime expiration = TimeTradeServer() + PeriodSeconds(PERIOD_M30);        
            //double precoReferencia = BarData[0].low;
            double precoReferencia = SymbolInfoDouble(_Symbol, SYMBOL_LAST);
            // operacao.SellStop(1,precoReferencia,_Symbol,precoReferencia + loss,precoReferencia - gain,ORDER_TIME_SPECIFIED,expiration);
            
            operacao.Sell(1, _Symbol, precoReferencia, precoReferencia + loss, precoReferencia - gain);

        }
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

string buscarSinal()
{
    ArraySetAsSeries(MediaZigZagHigh, true);
    ArraySetAsSeries(MediaZigZagLow, true);
    ArraySetAsSeries(MediaZigZag, true);

    CopyBuffer(mZigZag, 0, 0, 30, MediaZigZag);
    CopyBuffer(mZigZag, 1, 0, 100, MediaZigZagHigh);
    CopyBuffer(mZigZag, 2, 0, 100, MediaZigZagLow);    

    contadorTopo = 0;
    contadorFundo = 0;

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
    
    if (topo[1] > topo[2] 
    && topo[1] - topo[2] > diferencaTopoFundo
    && fundo[0] > fundo[1]
    && fundo[0] - fundo[1] > diferencaTopoFundo
    ) {
    
    return "Compra";
    
    }
    
    else if (topo[0] < topo[1] 
    && topo[1] - topo[0] > diferencaTopoFundo
    && fundo[1] < fundo[2]
    && fundo[2] - fundo[1] > diferencaTopoFundo
    ) {
    topoEntrada = fundo[0] ;
    return "Venda";
    }
    
    else return "Consolidacao";
    
     
    

    

}
