//+------------------------------------------------------------------+
//|                                                  Indicadores.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Leonardo Bezerra"
#property link      "https://www.mql5.com"

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>

class Indicadores

{
    public:
    
    
   
    void IncializaIndicadores(int &posicoes[], int mediaRapida, int mediaLonga);
    bool OrdemAberta(string ativo);
    void AtualizaIndicadoresTick(int &posicoes[], double &valorPorTick[]);
    bool horaOperar(string inicioPrimeiroPeriodo);
    void operacaoCorrente(float loss, float gain,string Ativo);
    string weis(int ticks, bool sinalTrigger, int weis,string &sinalWeis[],int &contadorWeis[],int qtdPeriodos,MqlRates &BarData[]);   
    string weismod(int ticks, bool sinalTrigger, int weis,string &sinalWeis[],int &contadorWeis[],int qtdPeriodos,MqlRates &BarData[]);   
    bool horarioFecharPosicaoIndice(string horarioMaximo,float precoAtual, string ativo, int tamanhoLote);
    bool StopGainMovel(float distanciaGain, float distanciaLoss, float proximoAlvo, string ativo, float precoAtual);
    
    
    /*string SentidoMedias(double mediaCurta, double media, double mediaLonga);
    bool StopGainMovel(float distanciaGain, float distanciaLoss, float proximoAlvo, string ativo, float precoAtual);    
    void BuscaUltimoTopoFundo(MqlRates &ultimasCotacoes[],double &topoFundo[],int quantidadeCandles);
    void BuscaUltimoTopoFundoPull(MqlRates &ultimasCotacoes[],double &topoFundo[],int quantidadeCandles);    
    double margemEntrada(double mediaCurta, double media, double mediaLonga,double PrecoTick,int margem);
    bool horarioFecharPosicaoDolar(string horarioMaximo,float precoAtual, string ativo, int tamanhoLote);
    bool horarioFecharPosicaoIndice(string horarioMaximo,float precoAtual, string ativo, int tamanhoLote);
    bool CompraAlvosLimite(float loss, float gain,string ativo, int tamanhoLote);
    bool VendaAlvosLimite(float loss, float gain,string ativo, int tamanhoLote);
    void FecharTudo(string ativo);
    bool CompraSemAlvos(string ativo, int tamanhoLote);
    bool VendaSemAlvos (string ativo, int tamanhoLote);
    bool StopGainLoss(string ativo, float precoAtual, int tamanhoLote);*/


};


/*============================= FUNCOES ========================================*/

CTrade trade;



bool Indicadores::OrdemAberta(string ativo)
{
    if (PositionSelect(ativo) == true) return true;
    else return false;
}

void Indicadores::IncializaIndicadores(int &posicoes[], int mediaRapida, int mediaLonga)
{
      posicoes[0] = iMA(_Symbol, _Period, mediaRapida, 0, MODE_EMA, PRICE_CLOSE);
      posicoes[1] = iMA(_Symbol, _Period, mediaLonga, 0, MODE_EMA, PRICE_CLOSE);     
}

void Indicadores::AtualizaIndicadoresTick(int &posicoes[], double &valorPorTick[])
{
    double MediaCurtaArray[];   
    double MediaLongaArray[];   

    ArraySetAsSeries(MediaCurtaArray, true);    
    ArraySetAsSeries(MediaLongaArray, true);
    
    CopyBuffer(posicoes[0], 0, 0, 3, MediaCurtaArray);    
    CopyBuffer(posicoes[1], 0, 0, 3, MediaLongaArray);    

    valorPorTick[0] = MediaCurtaArray[1];
    valorPorTick[1] = MediaLongaArray[1];      
}

bool Indicadores::horaOperar(string inicioPrimeiroPeriodo)
{
    datetime horaCorrente = TimeCurrent();

    string horaCorrenteStr = TimeToString(horaCorrente, TIME_MINUTES);    
    
    horaCorrente = StringToTime(   "2019.01.01 " + horaCorrenteStr);    

    if ( StringToTime(   "2019.01.01 " + horaCorrenteStr)  <= StringToTime(   "2019.01.01 " + inicioPrimeiroPeriodo) )
      {             
        return true;        
      }
    else
      {
        return false;
      }

}



void Indicadores::operacaoCorrente(float loss, float gain,string Ativo){

        
           PositionSelect(Ativo);
           ulong PositionTicket = PositionGetInteger(POSITION_TICKET);
           double StopLossCorrente = PositionGetDouble(POSITION_SL);
           double GainCorrente = PositionGetDouble(POSITION_TP);
           double PrecoAberturaPosicao = PositionGetDouble(POSITION_PRICE_OPEN);           
               
   
           if (StopLossCorrente < PrecoAberturaPosicao  && (GainCorrente - PrecoAberturaPosicao < gain || PrecoAberturaPosicao - StopLossCorrente < loss)){
           
           trade.PositionModify(PositionTicket, (PrecoAberturaPosicao - loss), (PrecoAberturaPosicao + gain));
           
           }
           
           else if (StopLossCorrente > PrecoAberturaPosicao &&  (PrecoAberturaPosicao - GainCorrente < gain || StopLossCorrente - PrecoAberturaPosicao < loss)){
           
           trade.PositionModify(PositionTicket, (PrecoAberturaPosicao + loss), (PrecoAberturaPosicao - gain)); 
           
           }    

}


string Indicadores::weis(int ticks, bool sinalTrigger, int weis,string &sinalWeis[],int &contadorWeis[],int qtdPeriodos,MqlRates &BarData[])
{ 
    
    double valorUltimoTopo = 0;
    double valorUltimoFundo = 1000000;   
    int i = qtdPeriodos - 1;

    if (BarData[i].close >= BarData[i - 1].close && (sinalWeis[weis] == "" || sinalWeis[weis] == "Compra"))
    {
        sinalWeis[weis] = "Compra";
        contadorWeis[weis]++;

        if (sinalTrigger) return "Nada";
        else return "Compra";
    }

    else if (BarData[i].close >= BarData[i - 1].close && (sinalWeis[weis] == "" || sinalWeis[weis] == "Venda"))
    {
        int x = 0;
        valorUltimoFundo = 1000000;

        for (x = 0; x < contadorWeis[weis]; x++)
        {        
            if (i - x > 0){
               if (BarData[i - x].close < valorUltimoFundo) valorUltimoFundo = BarData[i - x].close; 
            }      
        
        }

        if (BarData[i].close - valorUltimoFundo > ticks)
        {
            sinalWeis[weis] = "Compra";
            contadorWeis[weis] = 0;
            return "Compra";
        }

        else
        {
            sinalWeis[weis] = "Venda";
            contadorWeis[weis]++;
            if (sinalTrigger) return "Nada";
            else return "Venda";
        }
    }
    else if (BarData[i].close < BarData[i - 1].close && (sinalWeis[weis] == "" || sinalWeis[weis] == "Compra"))
    {
        valorUltimoTopo = 0;
        int x = 0;

        for (x = 0; x < contadorWeis[weis]; x++)
        {
            if (i - x > 0){
               if (BarData[i - x].close > valorUltimoTopo) valorUltimoTopo = BarData[i - x].close;
            }
        }

        if (valorUltimoTopo - BarData[i].close > ticks)
        {
            sinalWeis[weis] = "Venda";
            contadorWeis[weis] = 0;
            return "Venda";
        }

        else
        {
            sinalWeis[weis] = "Compra";
            contadorWeis[weis]++;

            if (sinalTrigger) return "Nada";
            else return "Compra";
        }

    }
    else if (BarData[i].close < BarData[i - 1].close && (sinalWeis[weis] == "" || sinalWeis[weis] == "Venda"))
    {
        sinalWeis[weis] = "Venda";
        contadorWeis[weis]++;

        if (sinalTrigger) return "Nada";
        else return "Venda";
    }

    return "Nada";
}

string Indicadores::weismod(int ticks, bool sinalTrigger, int weis,string &sinalWeis[],int &contadorWeis[],int qtdPeriodos,MqlRates &BarData[])
{ 
    
    double valorUltimoTopo = 0;
    double valorUltimoFundo = 1000000;   
    int i = qtdPeriodos - 1;

    if (BarData[i].close >= BarData[i - 1].close && (sinalWeis[weis] == "" || sinalWeis[weis] == "Compra"))
    {
        sinalWeis[weis] = "Compra";
        contadorWeis[weis]++;

        if (sinalTrigger) return "Nada";
        else return "Compra";
    }

    else if (BarData[i].close >= BarData[i - 1].close && (sinalWeis[weis] == "" || sinalWeis[weis] == "Venda"))
    {
        int x = 0;
        valorUltimoFundo = 1000000;

        for (x = 0; x < contadorWeis[weis]; x++)
        {        
            if (i - x > 0){
               if (BarData[i - x].close < valorUltimoFundo) valorUltimoFundo = BarData[i - x].close; 
            }      
        
        }

        if (BarData[i].close - valorUltimoFundo > ticks)
        {
            sinalWeis[weis] = "Compra";
            contadorWeis[weis] = 0;
            return "Compra";
        }

        else
        {
            sinalWeis[weis] = "Venda";
            contadorWeis[weis]++;
            if (sinalTrigger) return "Nada";
            else return "Venda";
        }
    }
    else if (BarData[i].close < BarData[i - 1].close && (sinalWeis[weis] == "" || sinalWeis[weis] == "Compra"))
    {
        valorUltimoTopo = 0;
        int x = 0;

        for (x = 0; x < contadorWeis[weis]; x++)
        {
            if (i - x > 0){
               if (BarData[i - x].close > valorUltimoTopo) valorUltimoTopo = BarData[i - x].close;
            }
        }

        if (valorUltimoTopo - BarData[i].close > ticks)
        {
            sinalWeis[weis] = "Venda";
            contadorWeis[weis] = 0;
            return "Venda";
        }

        else
        {
            sinalWeis[weis] = "Compra";
            contadorWeis[weis]++;

            if (sinalTrigger) return "Nada";
            else return "Compra";
        }

    }
    else if (BarData[i].close < BarData[i - 1].close && (sinalWeis[weis] == "" || sinalWeis[weis] == "Venda"))
    {
        sinalWeis[weis] = "Venda";
        contadorWeis[weis]++;

        if (sinalTrigger) return "Nada";
        else return "Venda";
    }

    return "Nada";
}

bool Indicadores::horarioFecharPosicaoIndice(string horarioMaximo,float precoAtual, string ativo, int tamanhoLote)
{

    if (OrdemAberta(ativo))
    {
        ulong PositionTicket = PositionGetInteger(POSITION_TICKET);
        double StopLossCorrente = PositionGetDouble(POSITION_SL);
        double GainCorrente = PositionGetDouble(POSITION_TP);
        double PrecoAberturaPosicao = PositionGetDouble(POSITION_PRICE_OPEN);
        
        
        datetime horaCorrente = TimeCurrent();

        string horaCorrenteStr = TimeToString(horaCorrente, TIME_MINUTES);

    
    
        horaCorrente = StringToTime(   "2019.01.01 " + horaCorrenteStr);
    


        if (StringToTime(   "2019.01.01 " + horaCorrenteStr) > StringToTime(   "2019.01.01 " + horarioMaximo))
        {
             if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)  trade.Sell(tamanhoLote, ativo, precoAtual);
             else trade.Buy(tamanhoLote, ativo, precoAtual);
             
             return true;
           
        }
        else return false;
        
        
    }
    return false;
   

}


bool Indicadores::StopGainMovel(float distanciaGain, float distanciaLoss, float proximoAlvo, string ativo, float precoAtual)
{

    if (OrdemAberta(ativo))
    {
        ulong PositionTicket = PositionGetInteger(POSITION_TICKET);
        double StopLossCorrente = PositionGetDouble(POSITION_SL);
        double GainCorrente = PositionGetDouble(POSITION_TP);
        double PrecoAberturaPosicao = PositionGetDouble(POSITION_PRICE_OPEN);

        if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
        {
            if (GainCorrente - precoAtual < distanciaGain)
            {
                trade.PositionModify(PositionTicket, precoAtual - distanciaLoss, precoAtual + proximoAlvo);
            }
        }
        else
        {
            if (precoAtual - GainCorrente < distanciaGain)
            {
                trade.PositionModify(PositionTicket, precoAtual + distanciaLoss, precoAtual - proximoAlvo);
            }
        }

        return true;
    }

    else return false;

}

/*============================= REVISAO ========================================*/

/*
bool Indicadores::VendaAlvosLimite(float loss, float gain,string ativo, int tamanhoLote){

    double ask = SymbolInfoDouble(ativo, SYMBOL_BID);
    if (!OrdemAberta(ativo))
    {
        trade.Sell(tamanhoLote, ativo, ask, ask + loss);
        //trade.Sell(tamanhoLote, ativo, ask);  
        //trade.Buy(tamanhoLote, ask - gain,ativo); 
        //trade.Buy(tamanhoLote, ask - gain, ativo);  
        //trade.Buy(tamanhoLote,ativo,ask - gain);
        trade.BuyLimit(tamanhoLote, ask - gain, ativo);
        
        //trade.BuyStop( tamanhoLote, ask - gain,ativo,0,0); 
        //LOGAR
        return true;
    }
    else
    {
        //LOGAR
        return false;
    }
}

bool Indicadores::CompraAlvosLimite(float loss, float gain,string ativo, int tamanhoLote)
{

    double bid = SymbolInfoDouble(ativo, SYMBOL_ASK);
    if (!OrdemAberta(ativo))
    {
        trade.Buy(tamanhoLote, ativo, bid, bid - loss);  
        //trade.Buy(tamanhoLote, ativo, bid);
        trade.SellLimit(tamanhoLote, bid + gain, ativo);  
        
        //trade.Sell(tamanhoLote,ativo,bid + gain);   
        //trade.SellStop( tamanhoLote, bid + gain,ativo,0,0); 
        //LOGAR
        
        
         
        
        //trade.OrderOpen(ativo,ORDER_TYPE_SELL,tamanhoLote,0,bid + gain,0,0);
        return true;
    }
    else
    {
        //LOGAR
        return false;
    }
}


void Indicadores::FecharTudo(string ativo)
{

    trade.PositionClose(ativo);
}







bool Indicadores::VendaSemAlvos (string ativo, int tamanhoLote){

    double ask = SymbolInfoDouble(ativo, SYMBOL_BID);
    if (!OrdemAberta(ativo))
    {
        trade.Sell(tamanhoLote, ativo, ask);        
        //LOGAR
        return true;
    }
    else
    {
        //LOGAR
        return false;
    }
}

bool Indicadores::CompraSemAlvos(string ativo, int tamanhoLote)
{

    double bid = SymbolInfoDouble(ativo, SYMBOL_ASK);
    if (!OrdemAberta(ativo))
    {
        trade.Buy(tamanhoLote, ativo, bid);        
        //LOGAR
        return true;
    }
    else
    {
        //LOGAR
        return false;
    }
}


bool Indicadores::StopGainMovel(float distanciaGain, float distanciaLoss, float proximoAlvo, string ativo, float precoAtual)
{

    if (OrdemAberta(ativo))
    {
        ulong PositionTicket = PositionGetInteger(POSITION_TICKET);
        double StopLossCorrente = PositionGetDouble(POSITION_SL);
        double GainCorrente = PositionGetDouble(POSITION_TP);
        double PrecoAberturaPosicao = PositionGetDouble(POSITION_PRICE_OPEN);

        if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
        {
            if (GainCorrente - precoAtual < distanciaGain)
            {
                MOdify(PositionTicket, precoAtual - distanciaLoss, precoAtual + proximoAlvo);
            }
        }
        else
        {
            if (precoAtual - GainCorrente < distanciaGain)
            {
                trade.PositionModify(PositionTicket, precoAtual + distanciaLoss, precoAtual - proximoAlvo);
            }
        }

        return true;
    }

    else return false;

}


bool Indicadores::StopGainLoss(string ativo, float precoAtual, int tamanhoLote)
{

    if (OrdemAberta(ativo))
    {
        ulong PositionTicket = PositionGetInteger(POSITION_TICKET);
        double StopLossCorrente = PositionGetDouble(POSITION_SL);
        double GainCorrente = PositionGetDouble(POSITION_TP);
        double PrecoAberturaPosicao = PositionGetDouble(POSITION_PRICE_OPEN);

        if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
        {
            
                trade.Sell(tamanhoLote, ativo, precoAtual); 
            
        }
        else
        {
            
                trade.Buy(tamanhoLote, ativo, precoAtual); 
           
        }

        return true;
    }

    else return false;

}






string Indicadores::SentidoMedias(double mediaCurta, double media, double mediaLonga)
{
    if (mediaCurta < media && media < mediaLonga) return "Venda";
    else if (mediaCurta > media && media > mediaLonga) return "Compra";
    else return "Consolidacao";
}

void Indicadores::BuscaUltimoTopoFundo(MqlRates &ultimasCotacoes[],double &topoFundo[],int quantidadeCandles)
{
    int x = 0;    
    double valorUltimoTopo = 0;
    double valorUltimoFundo = 1000000;

    for (x = 0; x <= quantidadeCandles - 1; x++)
    {          
            if (ultimasCotacoes[x].close > valorUltimoTopo) valorUltimoTopo = ultimasCotacoes[x].close ;          
            if (ultimasCotacoes[x].close < valorUltimoFundo) valorUltimoFundo = ultimasCotacoes[x].close ;                      
    }   
    
    topoFundo[0] = valorUltimoTopo;
    topoFundo[1] = valorUltimoFundo;

}

void Indicadores::BuscaUltimoTopoFundoPull(MqlRates &ultimasCotacoes[],double &topoFundo[],int quantidadeCandles)
{
    int x = 0;
    bool virou = false;    
    double valorUltimoTopo = 1000000;
    double valorUltimoFundo = 0;

    for (x = quantidadeCandles - 1; x >= 0; x--)
    {          
            if (ultimasCotacoes[x].close < valorUltimoTopo && !virou) valorUltimoTopo = ultimasCotacoes[x].close ;
            else if (!virou) { virou = true;valorUltimoTopo = ultimasCotacoes[x].close;}
            else if (ultimasCotacoes[x].close > valorUltimoTopo) valorUltimoTopo = ultimasCotacoes[x].close ;
            else break;       
    }
    
    virou = false;    
    
    for (x = quantidadeCandles - 1; x >= 0; x--)
    {
            if (ultimasCotacoes[x].close > valorUltimoFundo && !virou) valorUltimoFundo = ultimasCotacoes[x].close ;
            else if (!virou) { virou = true;valorUltimoFundo = ultimasCotacoes[x].close;}
            else if (ultimasCotacoes[x].close > valorUltimoFundo) valorUltimoFundo = ultimasCotacoes[x].close ;
            else break;       
    }
    
    topoFundo[0] = valorUltimoTopo;
    topoFundo[1] = valorUltimoFundo;

}



double Indicadores::margemEntrada(double mediaCurta, double media, double mediaLonga,double PrecoTick,int margem)
{

if ( (PrecoTick - mediaCurta < margem && PrecoTick - mediaCurta > -margem) || (mediaCurta - PrecoTick < margem  &&  mediaCurta - PrecoTick > -margem )) return mediaCurta;
//if ( (PrecoTick - media < margem && PrecoTick - media > -margem) || (media - PrecoTick < margem  &&  media - PrecoTick > -margem )) return media;
//if ( (PrecoTick - mediaLonga < margem && PrecoTick - mediaLonga > -margem) || (mediaLonga - PrecoTick < margem  &&  mediaLonga - PrecoTick > -margem )) return mediaLonga;
else return 0;

}


bool Indicadores::horarioFecharPosicaoIndice(string horarioMaximo,float precoAtual, string ativo, int tamanhoLote)
{

    if (OrdemAberta(ativo))
    {
        ulong PositionTicket = PositionGetInteger(POSITION_TICKET);
        double StopLossCorrente = PositionGetDouble(POSITION_SL);
        double GainCorrente = PositionGetDouble(POSITION_TP);
        double PrecoAberturaPosicao = PositionGetDouble(POSITION_PRICE_OPEN);
        
        
        datetime horaCorrente = TimeCurrent();

        string horaCorrenteStr = TimeToString(horaCorrente, TIME_MINUTES);

    
    
        horaCorrente = StringToTime(   "2019.01.01 " + horaCorrenteStr);
    


        if (StringToTime(   "2019.01.01 " + horaCorrenteStr) > StringToTime(   "2019.01.01 " + horarioMaximo))
        {
             if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)  trade.Sell(tamanhoLote, ativo, precoAtual);
             else trade.Buy(tamanhoLote, ativo, precoAtual);
             
             return true;
           
        }
        else return false;
        
        
    }
    return false;
   

}


bool Indicadores::horarioFecharPosicaoDolar(string horarioMaximo,float precoAtual, string ativo, int tamanhoLote)
{

    if (OrdemAberta(ativo))
    {
        ulong PositionTicket = PositionGetInteger(POSITION_TICKET);
        double StopLossCorrente = PositionGetDouble(POSITION_SL);
        double GainCorrente = PositionGetDouble(POSITION_TP);
        double PrecoAberturaPosicao = PositionGetDouble(POSITION_PRICE_OPEN);
        
        
        datetime horaCorrente = TimeCurrent();

        string horaCorrenteStr = TimeToString(horaCorrente, TIME_MINUTES);

    
    
        horaCorrente = StringToTime(   "2019.01.01 " + horaCorrenteStr);
    


        if (StringToTime(   "2019.01.01 " + horaCorrenteStr) > StringToTime(   "2019.01.01 " + horarioMaximo))
        {
             if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)  trade.Sell(tamanhoLote, ativo, precoAtual);
             else trade.Buy(tamanhoLote, ativo, precoAtual);
             
             return true;
           
        }
        else return false;
        
        
    }
    return false;
   

}
*/