create or replace PACKAGE GENEROWANIE_PROJEKT AS 

function fn_daj_losowa_ilosc_samochodu(v_numer_samochodu in bd_samochod.nr_samochodu%type) return bd_samochod.ilosc%type;
function fn_daj_numer_klienta return bd_klient.nr_klienta%type;
function fn_daj_samochod_losowo(v_date in date) return bd_samochod.nr_samochodu%type;

procedure generuj_dane;
procedure dodaj_samochod_klient_wojewodztwa;

END GENEROWANIE_PROJEKT;