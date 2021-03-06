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
input int qtdContratos = 1;        // Quantidade de contratos
input double gain = 50;            // GAIN
input double loss = 300;           // LOSS 
input double distancia = 70;       // Distancia VWAP
input double valorVWAP = 395;       // Distancia VWAP Band
input double qtdCandles = 3;       // Quantidade Candles Contra para Zerar
input double tamanhoMinimo = 10 ;    // Tamanho Minimo Candle
input string cabecario16;             // ====== HORARIOS =================
input string horarioAbrMin = "09:00"; // Abertura MIN
input string horarioAbrMax = "16:30"; // Abertura MAX
input string horarioFecMax = "17:30"; // Fechamento MAX
input string cabecario17;             // ====== METAS =====================
input double metaGainDi = 3000;        // Ganho Max Diario ($)
input double metaLossDi = -3000;       // Perda Max Diario ($)


//+------------------------------------------------------------------+
//|                                 |
//+------------------------------------------------------------------+

MqlRates BarData[1];

int mVwap1, mPivot, contador = 0,mVwap2;

double PPBuffer[], S1Buffer[], S2Buffer[], S3Buffer[], R1Buffer[], R2Buffer[], R3Buffer[];

double Vwap1Array[];
double Vwap2Array[];
double Vwap3Array[];
double Vwap4Array[];
double Vwap5Array[];
double Vwap6Array[];
double Vwap7Array[];

double tamanhoCandle;

bool mudouCandle = false, ordemAberta = false;

datetime horaPenultimoFechamento;


//+------------------------------------------------------------------+
//|                                 |
//+------------------------------------------------------------------+

int OnInit()
{
    mVwap1 = iCustom(_Symbol, _Period, "VWAP3",valorVWAP);
    mVwap2 = iCustom(_Symbol, _Period, "VWAP3",-valorVWAP);
    mPivot = iCustom(_Symbol, _Period, "pivotpoint");


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



        ArraySetAsSeries(PPBuffer, true);
        ArraySetAsSeries(R1Buffer, true);
        ArraySetAsSeries(R2Buffer, true);
        ArraySetAsSeries(R3Buffer, true);
        ArraySetAsSeries(S1Buffer, true);
        ArraySetAsSeries(S2Buffer, true);
        ArraySetAsSeries(S3Buffer, true);

        CopyBuffer(mPivot, 0, 0, 3, R3Buffer);
        CopyBuffer(mPivot, 1, 0, 3, R2Buffer);
        CopyBuffer(mPivot, 2, 0, 3, R1Buffer);
        CopyBuffer(mPivot, 3, 0, 3, PPBuffer);
        CopyBuffer(mPivot, 4, 0, 3, S1Buffer);
        CopyBuffer(mPivot, 5, 0, 3, S2Buffer);
        CopyBuffer(mPivot, 6, 0, 3, S3Buffer);


        ordemAberta = OrdemAberta(_Symbol);
        
        ArraySetAsSeries(Vwap1Array, true);
        ArraySetAsSeries(Vwap2Array, true);
        ArraySetAsSeries(Vwap3Array, true);
        ArraySetAsSeries(Vwap4Array, true);
        ArraySetAsSeries(Vwap5Array, true);
        ArraySetAsSeries(Vwap6Array, true);
        ArraySetAsSeries(Vwap7Array, true);
        
        
        CopyBuffer(mVwap1, 0, 0, 3, Vwap1Array);
        
        CopyBuffer(mVwap1, 3, 0, 3, Vwap4Array);
        CopyBuffer(mVwap1, 4, 0, 3, Vwap5Array);
        CopyBuffer(mVwap1, 5, 0, 3, Vwap6Array);
        
        
        CopyBuffer(mVwap2, 3, 0, 3, Vwap2Array);
        CopyBuffer(mVwap2, 4, 0, 3, Vwap3Array);        
        CopyBuffer(mVwap2, 5, 0, 3, Vwap7Array);
        
        


        if (ordemAberta)
        {
            horarioFecharPosicao(horarioFecMax, SymbolInfoDouble(_Symbol, SYMBOL_LAST), _Symbol, qtdContratos);

        }

        if (horaOperarMax(horarioAbrMax) && horaOperarMin(horarioAbrMin) && !ordemAberta && !funcao_verifica_meta_ou_perda_atingida("Meta", metaLossDi, metaGainDi, true))
        {
            if (
                ((Vwap1Array[0] - BarData[0].close < distancia && Vwap1Array[0] - BarData[0].close > 0) || (BarData[0].close - Vwap1Array[0] < distancia && BarData[0].close - Vwap1Array[0] > 0)) ||
                ((Vwap4Array[0] - BarData[0].close < distancia && Vwap4Array[0] - BarData[0].close > 0) || (BarData[0].close - Vwap4Array[0] < distancia && BarData[0].close - Vwap4Array[0] > 0)) ||
                ((Vwap5Array[0] - BarData[0].close < distancia && Vwap5Array[0] - BarData[0].close > 0) || (BarData[0].close - Vwap5Array[0] < distancia && BarData[0].close - Vwap5Array[0] > 0)) ||
                ((Vwap6Array[0] - BarData[0].close < distancia && Vwap6Array[0] - BarData[0].close > 0) || (BarData[0].close - Vwap6Array[0] < distancia && BarData[0].close - Vwap6Array[0] > 0)) ||
                ((Vwap2Array[0] - BarData[0].close < distancia && Vwap2Array[0] - BarData[0].close > 0) || (BarData[0].close - Vwap2Array[0] < distancia && BarData[0].close - Vwap2Array[0] > 0)) ||
                ((Vwap3Array[0] - BarData[0].close < distancia && Vwap3Array[0] - BarData[0].close > 0) || (BarData[0].close - Vwap3Array[0] < distancia && BarData[0].close - Vwap3Array[0] > 0)) ||
                ((Vwap7Array[0] - BarData[0].close < distancia && Vwap7Array[0] - BarData[0].close > 0) || (BarData[0].close - Vwap7Array[0] < distancia && BarData[0].close - Vwap7Array[0] > 0)) ||
                
                ((R1Buffer[0] - BarData[0].close < distancia && R1Buffer[0] - BarData[0].close > 0) || (BarData[0].close - R1Buffer[0] < distancia && BarData[0].close - R1Buffer[0] > 0)) ||
                ((R2Buffer[0] - BarData[0].close < distancia && R2Buffer[0] - BarData[0].close > 0) || (BarData[0].close - R2Buffer[0] < distancia && BarData[0].close - R2Buffer[0] > 0)) ||
                ((R3Buffer[0] - BarData[0].close < distancia && R3Buffer[0] - BarData[0].close > 0) || (BarData[0].close - R3Buffer[0] < distancia && BarData[0].close - R3Buffer[0] > 0)) ||
                ((PPBuffer[0] - BarData[0].close < distancia && PPBuffer[0] - BarData[0].close > 0) || (BarData[0].close - PPBuffer[0] < distancia && BarData[0].close - PPBuffer[0] > 0)) ||
                ((S1Buffer[0] - BarData[0].close < distancia && S1Buffer[0] - BarData[0].close > 0) || (BarData[0].close - S1Buffer[0] < distancia && BarData[0].close - S1Buffer[0] > 0)) ||
                ((S2Buffer[0] - BarData[0].close < distancia && S2Buffer[0] - BarData[0].close > 0) || (BarData[0].close - S2Buffer[0] < distancia && BarData[0].close - S2Buffer[0] > 0)) ||
                ((S3Buffer[0] - BarData[0].close < distancia && S3Buffer[0] - BarData[0].close > 0) || (BarData[0].close - S3Buffer[0] < distancia && BarData[0].close - S3Buffer[0] > 0))


             )
             
             
             
            {
            
            tamanhoCandle = BarData[0].close - BarData[0].open;
             if (tamanhoCandle < 0) tamanhoCandle = tamanhoCandle * -1;
            
            
            
            
                if (BarData[0].close > BarData[0].open && tamanhoCandle > tamanhoMinimo
                //&& (BarHist[0].close < BarHist[1].close && BarHist[1].close < BarHist[2].close && BarHist[0].low < BarHist[1].low && BarHist[1].low < BarHist[2].low)
                )
                {
                    operacao.Sell(qtdContratos, _Symbol, SymbolInfoDouble(_Symbol, SYMBOL_LAST), SymbolInfoDouble(_Symbol, SYMBOL_LAST) + loss, SymbolInfoDouble(_Symbol, SYMBOL_LAST) - gain);
                    //operacao.OrderOpen(_Symbol, ORDER_TYPE_SELL_LIMIT, qtdContratos, BarData[0].close - margem, BarData[0].close - margem, BarData[0].close + loss + margem, BarData[0].close - gain - margem, ORDER_TIME_SPECIFIED, TimeTradeServer() + PeriodSeconds(PERIOD_M30));
                    contador = 0;

                }
                else if (BarData[0].close < BarData[0].open && tamanhoCandle > tamanhoMinimo
                //&& (BarHist[0].close > BarHist[1].close && BarHist[1].close > BarHist[2].close && BarHist[0].high > BarHist[1].high && BarHist[1].high > BarHist[2].high)
                )
                {
                    operacao.Buy(qtdContratos, _Symbol, SymbolInfoDouble(_Symbol, SYMBOL_LAST), SymbolInfoDouble(_Symbol, SYMBOL_LAST) - loss, SymbolInfoDouble(_Symbol, SYMBOL_LAST) + gain);
                    //operacao.OrderOpen(_Symbol, ORDER_TYPE_BUY_LIMIT, qtdContratos, BarData[0].close + margem, BarData[0].close + margem, BarData[0].close - loss - margem, BarData[0].close + gain + margem, ORDER_TIME_SPECIFIED, TimeTradeServer() + PeriodSeconds(PERIOD_M30));
                    contador = 0;

                }
            }
        }

    }


    if (ordemAberta && mudouCandle)
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

    }


}
//+------------------------------------------------------------------+


bool VerificarMudouCandle()
{
    if (BarData[0].time != horaPenultimoFechamento)
    {
        horaPenultimoFechamento = BarData[0].time;
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


bool horaOperarMax(string inicioPrimeiroPeriodo)
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

bool horaOperarMin(string inicioPrimeiroPeriodo)
{
    datetime horaCorrente = TimeCurrent();

    string horaCorrenteStr = TimeToString(horaCorrente, TIME_MINUTES);

    horaCorrente = StringToTime("2020.01.01 " + horaCorrenteStr);

    if (StringToTime("2020.01.01 " + horaCorrenteStr) >= StringToTime("2020.01.01 " + inicioPrimeiroPeriodo))
    {
        return true;
    }
    else
    {
        return false;
    }
}

bool funcao_verifica_meta_ou_perda_atingida(string tmpOrigem, double tmpValorMaximoPerda, double tmpValor_Maximo_Ganho, bool tmp_placar)
{


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

bool horarioFecharPosicao(string horarioMaximo, float precoAtualF, string ativo, int tamanhoLote)
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