//+------------------------------------------------------------------+
//|                                               ROBOLAB_CANDLE.mq5 |
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

input string cabecario1;              // ====== ALVO/LOSS - NORMAL ========
input int qtdContratos = 1;           // Quantidade de contratos 
input double gain = 50;               // GAIN Minimo
input double loss = 300;              // LOSS Maximo
//input double margemEntrada = 0;     // Marge Entrada
input string cabecario16;             // ====== Stochastic =================
input int k = 5;                      // K 
input int r = 3;                      // R 
input int d = 3;                      // D 
input int FaixaVenda = 80;            // Faixa de Venda > %V
input int FaixaCompra = 20;           // Faixa de Compra < %V
input string cabecario18;             // ====== HORARIOS =================
input string horarioAbrMin = "09:00"; // Abertura MIN
input string horarioAbrMax = "17:00"; // Abertura MAX
input string horarioFecMax = "17:30"; // Fechamento MAX

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

int ultimoCandle = 0;

int mPivot;
int mMacd;
int mMO;
int media;
int msto;

double PPBuffer[];
double S1Buffer[];
double R1Buffer[];
double S2Buffer[];
double R2Buffer[];
double S3Buffer[];
double R3Buffer[];
double macdArray[];

double moArray[];
double mediaArray[];

double VPPBuffer;
double VS1Buffer;
double VR1Buffer;
double VS2Buffer;
double VR2Buffer;
double VS3Buffer;
double VR3Buffer;


double stoArray[];
double stoArray2[];

//int contador = 0;
ENUM_ORDER_TYPE tipoOrdem;

int div;

double precoAtual;

double PrecoFechamentoPenultimoCandle = 1;

MqlRates BarData[1];

bool ordemAberta = false;
bool mudouCandle = false;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    //---
    mPivot = iCustom(_Symbol, _Period, "pivotpoint");
    //mMacd = iMACD(_Symbol, _Period, 12, 26, 9, PRICE_CLOSE);
    //mMO = iMomentum(_Symbol, _Period, 28, PRICE_CLOSE);
    //media = iMA(_Symbol, _Period, 9, 0, MODE_EMA, PRICE_CLOSE);
    msto = iStochastic(_Symbol,_Period,5,3,3,MODE_SMA,STO_LOWHIGH);
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
    //---

    CopyRates(_Symbol, _Period, 1, 1, BarData);
    mudouCandle = VerificarMudouCandle();

    if (mudouCandle)
    {

        fecharTodasOrdensPendentes();

        ordemAberta = OrdemAberta(_Symbol);

        if (ordemAberta)
        {

            horarioFecharPosicaoIndice(horarioFecMax, SymbolInfoDouble(_Symbol, SYMBOL_LAST), _Symbol, qtdContratos);
            //horarioFecharPosicaoIndice3();
            //contador++;

        }

        //ArraySetAsSeries(macdArray, true);
        //CopyBuffer(mMacd, 0, 0, 3, macdArray);
        
        /*ArraySetAsSeries(moArray, true);
        CopyBuffer(mMO, 0, 0, 3, moArray);
        
        ArraySetAsSeries(mediaArray, true);
        CopyBuffer(media, 0, 0, 3, mediaArray);*/
        
     
        
        

        ArraySetAsSeries(PPBuffer, true);
        ArraySetAsSeries(S1Buffer, true);
        ArraySetAsSeries(R1Buffer, true);
        ArraySetAsSeries(S2Buffer, true);
        ArraySetAsSeries(R2Buffer, true);
        ArraySetAsSeries(S3Buffer, true);
        ArraySetAsSeries(R3Buffer, true);


        CopyBuffer(mPivot, 0, 0, 3, R3Buffer);
        CopyBuffer(mPivot, 1, 0, 3, R2Buffer);
        CopyBuffer(mPivot, 2, 0, 3, R1Buffer);
        CopyBuffer(mPivot, 3, 0, 3, PPBuffer);
        CopyBuffer(mPivot, 4, 0, 3, S1Buffer);
        CopyBuffer(mPivot, 5, 0, 3, S2Buffer);
        CopyBuffer(mPivot, 6, 0, 3, S3Buffer);
        
         ArraySetAsSeries(stoArray, true);
         ArraySetAsSeries(stoArray2, true);


        CopyBuffer(msto, 0, 0, 3, stoArray);
        CopyBuffer(msto, 1, 0, 3, stoArray2);       


        div = PPBuffer[0] / 5;

        VPPBuffer = div * 5;

        div = S1Buffer[0] / 5;

        VS1Buffer = div * 5;

        div = R1Buffer[0] / 5;

        VR1Buffer = div * 5;

        div = S2Buffer[0] / 5;

        VS2Buffer = div * 5;

        div = R2Buffer[0] / 5;

        VR2Buffer = div * 5;

        div = S3Buffer[0] / 5;

        VS3Buffer = div * 5;

        div = R3Buffer[0] / 5;

        VR3Buffer = div * 5;

        precoAtual = SymbolInfoDouble(_Symbol, SYMBOL_LAST);



         if (
            ((BarData[0].high > VPPBuffer && BarData[0].open < VPPBuffer) ||
            (BarData[0].high > VS1Buffer && BarData[0].open < VS1Buffer) ||
            (BarData[0].high > VS2Buffer && BarData[0].open < VS2Buffer) ||
            (BarData[0].high > VS3Buffer && BarData[0].open < VS3Buffer) ||
            (BarData[0].high > VR1Buffer && BarData[0].open < VR1Buffer) ||
            (BarData[0].high > VR2Buffer && BarData[0].open < VR2Buffer) ||
            (BarData[0].high > VR3Buffer && BarData[0].open < VR3Buffer)) && stoArray[1] <  stoArray2[1] && !ordemAberta && stoArray[1] > FaixaVenda &&  horaOperar(horarioAbrMax)
            )
            {
            
            
            operacao.Sell(qtdContratos,_Symbol,BarData[0].close,BarData[0].close + loss,BarData[0].close - gain);
            //operacao.OrderOpen(_Symbol, ORDER_TYPE_SELL_STOP_LIMIT, qtdContratos, BarData[0].close - margemEntrada, BarData[0].close - margemEntrada, BarData[0].close + loss - margemEntrada, BarData[0].close - gain - margemEntrada, ORDER_TIME_SPECIFIED, TimeTradeServer() + PeriodSeconds(PERIOD_M5));
            
            }
            
            
            else if (
            ((BarData[0].low < VPPBuffer && BarData[0].open > VPPBuffer) ||
            (BarData[0].low < VS1Buffer && BarData[0].open > VS1Buffer) ||
            (BarData[0].low < VS2Buffer && BarData[0].open > VS2Buffer) ||
            (BarData[0].low < VS3Buffer && BarData[0].open > VS3Buffer) ||
            (BarData[0].low < VR1Buffer && BarData[0].open > VR1Buffer) ||
            (BarData[0].low < VR2Buffer && BarData[0].open > VR2Buffer) ||
            (BarData[0].low < VR3Buffer && BarData[0].open > VR3Buffer)) && stoArray[1] >  stoArray2[1] && !ordemAberta && stoArray[1] < FaixaCompra &&  horaOperar(horarioAbrMax)
            )
            {
            
            
            operacao.Buy(qtdContratos,_Symbol,BarData[0].close,BarData[0].close - loss,BarData[0].close + gain);
            //operacao.OrderOpen(_Symbol, ORDER_TYPE_SELL_STOP_LIMIT, qtdContratos, BarData[0].close - margemEntrada, BarData[0].close - margemEntrada, BarData[0].close + loss - margemEntrada, BarData[0].close - gain - margemEntrada, ORDER_TIME_SPECIFIED, TimeTradeServer() + PeriodSeconds(PERIOD_M5));
            
            }
            
            
        /*if (moArray[0] > 100 && !ordemAberta && horaOperar(horarioAbrMax) && precoAtual > mediaArray[0])
        {

            //contador = 0;


            if (VPPBuffer > precoAtual) tipoOrdem = ORDER_TYPE_BUY_STOP_LIMIT;
            else tipoOrdem = ORDER_TYPE_BUY_LIMIT;

            operacao.OrderOpen(_Symbol, tipoOrdem, qtdContratos, VPPBuffer + margemEntrada, VPPBuffer + margemEntrada, VPPBuffer - loss + margemEntrada, VPPBuffer + gain + margemEntrada, ORDER_TIME_SPECIFIED, TimeTradeServer() + PeriodSeconds(PERIOD_M5));


            if (VS1Buffer > precoAtual) tipoOrdem = ORDER_TYPE_BUY_STOP_LIMIT;
            else tipoOrdem = ORDER_TYPE_BUY_LIMIT;

            operacao.OrderOpen(_Symbol, tipoOrdem, qtdContratos, VS1Buffer + margemEntrada, VS1Buffer + margemEntrada, VS1Buffer - loss + margemEntrada, VS1Buffer + gain + margemEntrada, ORDER_TIME_SPECIFIED, TimeTradeServer() + PeriodSeconds(PERIOD_M5));


            if (VS2Buffer > precoAtual) tipoOrdem = ORDER_TYPE_BUY_STOP_LIMIT;
            else tipoOrdem = ORDER_TYPE_BUY_LIMIT;

            operacao.OrderOpen(_Symbol, tipoOrdem, qtdContratos, VS2Buffer + margemEntrada , VS2Buffer + margemEntrada, VS2Buffer - loss + margemEntrada, VS2Buffer + gain + margemEntrada, ORDER_TIME_SPECIFIED, TimeTradeServer() + PeriodSeconds(PERIOD_M5));


            if (VS3Buffer > precoAtual) tipoOrdem = ORDER_TYPE_BUY_STOP_LIMIT;
            else tipoOrdem = ORDER_TYPE_BUY_LIMIT;

            operacao.OrderOpen(_Symbol, tipoOrdem, qtdContratos, VS3Buffer + margemEntrada, VS3Buffer + margemEntrada, VS3Buffer - loss + margemEntrada, VS3Buffer + gain + margemEntrada, ORDER_TIME_SPECIFIED, TimeTradeServer() + PeriodSeconds(PERIOD_M5));


            if (VR1Buffer > precoAtual) tipoOrdem = ORDER_TYPE_BUY_STOP_LIMIT;
            else tipoOrdem = ORDER_TYPE_BUY_LIMIT;

            operacao.OrderOpen(_Symbol, tipoOrdem, qtdContratos, VR1Buffer + margemEntrada, VR1Buffer + margemEntrada, VR1Buffer - loss + margemEntrada, VR1Buffer + gain + margemEntrada, ORDER_TIME_SPECIFIED, TimeTradeServer() + PeriodSeconds(PERIOD_M5));


            if (VR2Buffer > precoAtual) tipoOrdem = ORDER_TYPE_BUY_STOP_LIMIT;
            else tipoOrdem = ORDER_TYPE_BUY_LIMIT;

            operacao.OrderOpen(_Symbol, tipoOrdem, qtdContratos, VR2Buffer + margemEntrada, VR2Buffer + margemEntrada, VR2Buffer - loss + margemEntrada, VR2Buffer + gain + margemEntrada, ORDER_TIME_SPECIFIED, TimeTradeServer() + PeriodSeconds(PERIOD_M5));


            if (VR3Buffer > precoAtual) tipoOrdem = ORDER_TYPE_BUY_STOP_LIMIT;
            else tipoOrdem = ORDER_TYPE_BUY_LIMIT;

            operacao.OrderOpen(_Symbol, tipoOrdem, qtdContratos, VR3Buffer + margemEntrada, VR3Buffer + margemEntrada, VR3Buffer - loss + margemEntrada, VR3Buffer + gain + margemEntrada, ORDER_TIME_SPECIFIED, TimeTradeServer() + PeriodSeconds(PERIOD_M5));

        }

        else if (moArray[0] < 100 && !ordemAberta && horaOperar(horarioAbrMax)&& precoAtual < mediaArray[0])
        {

            //contador = 0;

            if (VPPBuffer < precoAtual) tipoOrdem = ORDER_TYPE_SELL_STOP_LIMIT;
            else tipoOrdem = ORDER_TYPE_SELL_LIMIT;

            operacao.OrderOpen(_Symbol, tipoOrdem, qtdContratos, VPPBuffer - margemEntrada, VPPBuffer - margemEntrada, VPPBuffer + loss  - margemEntrada, VPPBuffer - gain - margemEntrada, ORDER_TIME_SPECIFIED, TimeTradeServer() + PeriodSeconds(PERIOD_M5));

            if (VS1Buffer < precoAtual) tipoOrdem = ORDER_TYPE_SELL_STOP_LIMIT;
            else tipoOrdem = ORDER_TYPE_SELL_LIMIT;

            operacao.OrderOpen(_Symbol, tipoOrdem, qtdContratos, VS1Buffer - margemEntrada, VS1Buffer - margemEntrada, VS1Buffer + loss - margemEntrada, VS1Buffer - gain - margemEntrada, ORDER_TIME_SPECIFIED, TimeTradeServer() + PeriodSeconds(PERIOD_M5));


            if (VR1Buffer < precoAtual) tipoOrdem = ORDER_TYPE_SELL_STOP_LIMIT;
            else tipoOrdem = ORDER_TYPE_SELL_LIMIT;

            operacao.OrderOpen(_Symbol, tipoOrdem, qtdContratos, VR1Buffer - margemEntrada, VR1Buffer - margemEntrada, VR1Buffer + loss - margemEntrada, VR1Buffer - gain - margemEntrada, ORDER_TIME_SPECIFIED, TimeTradeServer() + PeriodSeconds(PERIOD_M5));

            if (VS2Buffer < precoAtual) tipoOrdem = ORDER_TYPE_SELL_STOP_LIMIT;
            else tipoOrdem = ORDER_TYPE_SELL_LIMIT;

            operacao.OrderOpen(_Symbol, tipoOrdem, qtdContratos, VS2Buffer - margemEntrada, VS2Buffer - margemEntrada, VS2Buffer + loss - margemEntrada, VS2Buffer - gain - margemEntrada, ORDER_TIME_SPECIFIED, TimeTradeServer() + PeriodSeconds(PERIOD_M5));

            if (VR2Buffer < precoAtual) tipoOrdem = ORDER_TYPE_SELL_STOP_LIMIT;
            else tipoOrdem = ORDER_TYPE_SELL_LIMIT;

            operacao.OrderOpen(_Symbol, tipoOrdem, qtdContratos, VR2Buffer - margemEntrada, VR2Buffer - margemEntrada, VR2Buffer + loss - margemEntrada, VR2Buffer - gain - margemEntrada, ORDER_TIME_SPECIFIED, TimeTradeServer() + PeriodSeconds(PERIOD_M5));


            if (VS3Buffer < precoAtual) tipoOrdem = ORDER_TYPE_SELL_STOP_LIMIT;
            else tipoOrdem = ORDER_TYPE_SELL_LIMIT;

            operacao.OrderOpen(_Symbol, tipoOrdem, qtdContratos, VS3Buffer - margemEntrada, VS3Buffer - margemEntrada, VS3Buffer + loss - margemEntrada, VS3Buffer - gain - margemEntrada, ORDER_TIME_SPECIFIED, TimeTradeServer() + PeriodSeconds(PERIOD_M5));


            if (VR3Buffer < precoAtual) tipoOrdem = ORDER_TYPE_SELL_STOP_LIMIT;
            else tipoOrdem = ORDER_TYPE_SELL_LIMIT;

            operacao.OrderOpen(_Symbol, tipoOrdem, qtdContratos, VR3Buffer - margemEntrada, VR3Buffer - margemEntrada, VR3Buffer + loss - margemEntrada, VR3Buffer - gain - margemEntrada, ORDER_TIME_SPECIFIED, TimeTradeServer() + PeriodSeconds(PERIOD_M5));

        }*/

    }

}
//+------------------------------------------------------------------+



bool VerificarMudouCandle()
{
    if (BarData[ultimoCandle].close != PrecoFechamentoPenultimoCandle)
    {
        PrecoFechamentoPenultimoCandle = BarData[ultimoCandle].close;
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

void fecharTodasOrdensPendentes()
{


    uint total = OrdersTotal();    

    for (uint i = 0; i < total; i++)

    {

        MqlTradeRequest request = { 0 };
        MqlTradeResult result = { 0 };

        ulong order_ticket = OrderGetTicket(0);

        ZeroMemory(request);
        ZeroMemory(result);
        //--- setting the operation parameters
        request.action = TRADE_ACTION_REMOVE;
        request.order = order_ticket;

        if (order_ticket != 0)

        {
            printf (OrderSend(request, result));

        }

    }

}

void horarioFecharPosicaoIndice3()
{


    ulong PositionTicket = PositionGetInteger(POSITION_TICKET);
    double StopLossCorrente = PositionGetDouble(POSITION_SL);
    double GainCorrente = PositionGetDouble(POSITION_TP);
    double PrecoAberturaPosicao = PositionGetDouble(POSITION_PRICE_OPEN);

    if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
        //  operacao.PositionModify(PositionTicket, precoAtual + 20, precoAtual - 20);
        operacao.Sell(qtdContratos, _Symbol, precoAtual);

    else
        operacao.Buy(qtdContratos, _Symbol, precoAtual);
    //  operacao.PositionModify(PositionTicket, precoAtual - 20, precoAtual + 20);

}



bool horarioFecharPosicaoIndice(string horarioMaximo, float precoAtualF, string ativo, int tamanhoLote)
{


    ulong PositionTicket = PositionGetInteger(POSITION_TICKET);
    double StopLossCorrente = PositionGetDouble(POSITION_SL);
    double GainCorrente = PositionGetDouble(POSITION_TP);
    double PrecoAberturaPosicao = PositionGetDouble(POSITION_PRICE_OPEN);

    datetime horaCorrente = TimeCurrent();

    string horaCorrenteStr = TimeToString(horaCorrente, TIME_MINUTES);

    horaCorrente = StringToTime("2019.01.01 " + horaCorrenteStr);

    if (StringToTime("2019.01.01 " + horaCorrenteStr) > StringToTime("2019.01.01 " + horarioMaximo))
    {
        if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
            //  operacao.PositionModify(PositionTicket, precoAtual + 20, precoAtual - 20);
            operacao.Sell(tamanhoLote, ativo, precoAtualF);

        else
            operacao.Buy(tamanhoLote, ativo, precoAtualF);
        //  operacao.PositionModify(PositionTicket, precoAtual - 20, precoAtual + 20);

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