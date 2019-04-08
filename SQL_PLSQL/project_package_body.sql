create or replace PACKAGE BODY GENEROWANIE_PROJEKT AS
  
  function fn_daj_losowa_ilosc_samochodu(v_numer_samochodu in bd_samochod.nr_samochodu%type) return bd_samochod.ilosc%type AS
    v_ilosc bd_samochod.ilosc%type;
    v_zwroc bd_samochod.ilosc%type;
    begin
    
    select ilosc into v_ilosc
    from bd_samochod
    where nr_samochodu=v_numer_samochodu;
    v_ilosc:=round((v_ilosc/2));
    
    if v_ilosc=0 then
    return 0;
    else
    select round(dbms_random.value(1,v_ilosc)) into v_zwroc
    from dual;
    return v_zwroc;
    end if;
    end fn_daj_losowa_ilosc_samochodu;
  
  function fn_daj_numer_klienta return bd_klient.nr_klienta%type AS
    v_tmp bd_klient.nr_klienta%type;
    begin
    
    select * into v_tmp from(
    select nr_klienta
    from bd_klient
    order by dbms_random.value)
    where rownum=1;
    
    return v_tmp;
    end fn_daj_numer_klienta;
  
  function fn_daj_samochod_losowo(v_date in date) return bd_samochod.nr_samochodu%type as
    v_numer bd_samochod.nr_samochodu%type;
    begin
    
    select * into v_numer from(
    select nr_samochodu
    from bd_samochod
    where bd_samochod.ROK_PROD=extract(year from v_date)
    order by dbms_random.value)
    where rownum=1;
    
    return v_numer;
    end fn_daj_samochod_losowo;
  
  procedure generuj_dane AS
  BEGIN
    declare
    v_nr_klienta bd_klient.nr_klienta%type;
    v_nr_faktury bd_faktura.nr_faktury%type;
    v_data_sprzedazy_faktury date;
    v_nr_samochodu bd_samochod.nr_samochodu%type;
    v_ilosc bd_samochod.ilosc%type;
    v_ile_samochodow_z_roku bd_samochod.nr_samochodu%type;
    v_counter number;
    v_losowa_ilosc_samochodu bd_samochod.nr_samochodu%type;
    v_czy_jest_juz number;
    v_zakonczenie_petli_ile number;
    v_zakonczenie_petli_data date;
    v_stop boolean;
    begin
    
    v_stop:=false;
    
    while v_stop!=true loop
    
    select count(*) into v_zakonczenie_petli_ile
    from bd_faktura;
    
    if v_zakonczenie_petli_ile=0 then
        v_zakonczenie_petli_data:='18/01/01';
    else
        select max(data_sprzedazy) into v_zakonczenie_petli_data
        from bd_faktura;
    end if;
    
    if v_zakonczenie_petli_data+13<='19/12/31' then
    
    v_nr_klienta:=fn_daj_numer_klienta();
    
    insert into bd_faktura(nr_klienta)
    values(
    v_nr_klienta);
    
    --pobieram nr faktury na ktorej dzialam
    select nr_faktury into v_nr_faktury
    from bd_faktura where status='OTWARTA';
    
    select data_sprzedazy into v_data_sprzedazy_faktury from bd_faktura
    where nr_faktury=v_nr_faktury;
    
    --teraz robie zapytanie, ktore bd odpowiadalo za ilosc generowanych rekordow
    
    select count(*) into v_ile_samochodow_z_roku
    from bd_samochod
    where rok_prod=(extract(year from v_data_sprzedazy_faktury));
    
    select round(dbms_random.value(1,v_ile_samochodow_z_roku)) into v_losowa_ilosc_samochodu
    from dual;
    
    v_counter:=0;
    
    while v_counter!=v_losowa_ilosc_samochodu loop
    
    v_nr_samochodu:=fn_daj_samochod_losowo(v_data_sprzedazy_faktury);
    
    select count(*) into v_czy_jest_juz
    from bd_pozycja_faktury
    where nr_faktury=v_nr_faktury and nr_samochodu=v_nr_samochodu;
    
    if v_czy_jest_juz=0 then
    
    v_ilosc:=fn_daj_losowa_ilosc_samochodu(v_nr_samochodu);
    
    if v_ilosc>0 then
    
    insert into bd_pozycja_faktury(nr_faktury,ilosc,nr_samochodu)
    values(
    v_nr_faktury,v_ilosc,v_nr_samochodu
    );
    
    v_counter:=v_counter+1;
    end if;
    end if;
    
    end loop;
    
    --zmieniam status faktury na Zakonczona
    
    update bd_faktura
    set status='ZAMKNIETA'
    where nr_faktury=v_nr_faktury;
    
    elsif v_zakonczenie_petli_data+13>'19/12/31' then
    v_stop:=true;
    end if;
    
    end loop;
        
        end;
  
  END generuj_dane;
  
  procedure dodaj_samochod_klient_wojewodztwa as
  begin
  
    Insert into BD_SAMOCHOD (MARKA,MODEL,ROK_PROD,KOLOR,CENA,ILOSC) values ('Opel','Astra','2018','CZARNY','56000','3');
    Insert into BD_SAMOCHOD (MARKA,MODEL,ROK_PROD,KOLOR,CENA,ILOSC) values ('Opel','Insignia','2019','CZERWONY','76000','5');
    Insert into BD_SAMOCHOD (MARKA,MODEL,ROK_PROD,KOLOR,CENA,ILOSC) values ('Opel','Insignia','2018','CZERWONY','72000','3');
    Insert into BD_SAMOCHOD (MARKA,MODEL,ROK_PROD,KOLOR,CENA,ILOSC) values ('Opel','Vectra','2018','ZIELONY','46000','5');
    Insert into BD_SAMOCHOD (MARKA,MODEL,ROK_PROD,KOLOR,CENA,ILOSC) values ('Opel','Vectra','2019','ZIELONY','49000','5');
    Insert into BD_SAMOCHOD (MARKA,MODEL,ROK_PROD,KOLOR,CENA,ILOSC) values ('Polonez','Caro','2019','BORDOWY','41000','5');
    Insert into BD_SAMOCHOD (MARKA,MODEL,ROK_PROD,KOLOR,CENA,ILOSC) values ('Polonez','Caro','2018','BIALY','36000','3');
    Insert into BD_SAMOCHOD (MARKA,MODEL,ROK_PROD,KOLOR,CENA,ILOSC) values ('Seat','Toledo','2019','BIALY','81000','5');
    Insert into BD_SAMOCHOD (MARKA,MODEL,ROK_PROD,KOLOR,CENA,ILOSC) values ('Seat','Toledo','2018','BIALY','76000','5');
    Insert into BD_SAMOCHOD (MARKA,MODEL,ROK_PROD,KOLOR,CENA,ILOSC) values ('Seat','Cordoba','2018','SZARY','52000','2');
    Insert into BD_SAMOCHOD (MARKA,MODEL,ROK_PROD,KOLOR,CENA,ILOSC) values ('Seat','Cordoba','2019','SZARY','57000','5');
    Insert into BD_SAMOCHOD (MARKA,MODEL,ROK_PROD,KOLOR,CENA,ILOSC) values ('Seat','Exeo','2018','GRANATOWY','89000','2');
    Insert into BD_SAMOCHOD (MARKA,MODEL,ROK_PROD,KOLOR,CENA,ILOSC) values ('Seat','Exeo','2019','ROZOWY','99000','5');
    Insert into BD_SAMOCHOD (MARKA,MODEL,ROK_PROD,KOLOR,CENA,ILOSC) values ('Volvo','S40','2018','ROZOWY','55000','3');
    Insert into BD_SAMOCHOD (MARKA,MODEL,ROK_PROD,KOLOR,CENA,ILOSC) values ('Volvo','S40','2019','CZARNY','60000','5');
    Insert into BD_SAMOCHOD (MARKA,MODEL,ROK_PROD,KOLOR,CENA,ILOSC) values ('Volvo','S60','2019','CZARNY','65000','5');
    Insert into BD_SAMOCHOD (MARKA,MODEL,ROK_PROD,KOLOR,CENA,ILOSC) values ('Volvo','S60','2018','NIEBIESKI','61000','3');
    Insert into BD_SAMOCHOD (MARKA,MODEL,ROK_PROD,KOLOR,CENA,ILOSC) values ('Volvo','S80','2018','NIEBIESKI','84000','5');
    Insert into BD_SAMOCHOD (MARKA,MODEL,ROK_PROD,KOLOR,CENA,ILOSC) values ('Volvo','S80','2019','ZOLTY','89000','5');
    Insert into BD_SAMOCHOD (MARKA,MODEL,ROK_PROD,KOLOR,CENA,ILOSC) values ('Volvo','S90','2019','CZERWONY','79000','5');
    Insert into BD_SAMOCHOD (MARKA,MODEL,ROK_PROD,KOLOR,CENA,ILOSC) values ('Volvo','S90','2018','CZERWONY','69000','5');
    Insert into BD_SAMOCHOD (MARKA,MODEL,ROK_PROD,KOLOR,CENA,ILOSC) values ('Porsche','Cayenne','2018','ZIELONY','100000','4');
    Insert into BD_SAMOCHOD (MARKA,MODEL,ROK_PROD,KOLOR,CENA,ILOSC) values ('Porsche','Cayenne','2019','SREBRNY','140000','3');
    Insert into BD_SAMOCHOD (MARKA,MODEL,ROK_PROD,KOLOR,CENA,ILOSC) values ('Porsche','Panamera','2019','BIALY','250000','1');
    Insert into BD_SAMOCHOD (MARKA,MODEL,ROK_PROD,KOLOR,CENA,ILOSC) values ('Porsche','Panamera','2018','POMARANCZOWY','230000','4');
    Insert into BD_SAMOCHOD (MARKA,MODEL,ROK_PROD,KOLOR,CENA,ILOSC) values ('Porsche','911','2018','POMARANCZOWY','650000','1');
    Insert into BD_SAMOCHOD (MARKA,MODEL,ROK_PROD,KOLOR,CENA,ILOSC) values ('Porsche','911','2019','ZLOTY','750000','1');
    Insert into BD_SAMOCHOD (MARKA,MODEL,ROK_PROD,KOLOR,CENA,ILOSC) values ('Fiat','500','2019','CZARNY','21500','5');
    Insert into BD_SAMOCHOD (MARKA,MODEL,ROK_PROD,KOLOR,CENA,ILOSC) values ('Fiat','500','2018','CZARNY','20500','5');
    Insert into BD_SAMOCHOD (MARKA,MODEL,ROK_PROD,KOLOR,CENA,ILOSC) values ('Nissan','Micra','2018','CZARNY','25500','3');
    Insert into BD_SAMOCHOD (MARKA,MODEL,ROK_PROD,KOLOR,CENA,ILOSC) values ('Nissan','350Z','2018','CZARNY','125500','2');
    Insert into BD_SAMOCHOD (MARKA,MODEL,ROK_PROD,KOLOR,CENA,ILOSC) values ('Seat','Alhambra','2018','SIWY','65500','2');
    
    Insert into BD_KLIENT (KLIENT_IMIE,KLIENT_NAZWISKO,KLIENT_ADRES,KLIENT_MIASTO,KOD_POCZTOWY,NR_WOJEWODZTWA) values ('Rafal','Piotrowski','Konwaliowa 5','Lublin','20-023','3');
    Insert into BD_KLIENT (KLIENT_IMIE,KLIENT_NAZWISKO,KLIENT_ADRES,KLIENT_MIASTO,KOD_POCZTOWY,NR_WOJEWODZTWA) values ('Krzysztof','Andersen','Waska 13','Rzeszow','35-032','9');
    Insert into BD_KLIENT (KLIENT_IMIE,KLIENT_NAZWISKO,KLIENT_ADRES,KLIENT_MIASTO,KOD_POCZTOWY,NR_WOJEWODZTWA) values ('Marek','Mostowiak','Pilsudskiego 135','Opole','45-016','8');
    Insert into BD_KLIENT (KLIENT_IMIE,KLIENT_NAZWISKO,KLIENT_ADRES,KLIENT_MIASTO,KOD_POCZTOWY,NR_WOJEWODZTWA) values ('Dariusz','Michalski','Piekna 21','Lodz','90-019','5');
    Insert into BD_KLIENT (KLIENT_IMIE,KLIENT_NAZWISKO,KLIENT_ADRES,KLIENT_MIASTO,KOD_POCZTOWY,NR_WOJEWODZTWA) values ('Barbara','Cichosz','Spokojna 1','Olsztyn','10-015','14');
    Insert into BD_KLIENT (KLIENT_IMIE,KLIENT_NAZWISKO,KLIENT_ADRES,KLIENT_MIASTO,KOD_POCZTOWY,NR_WOJEWODZTWA) values ('Teofila','Kowalska','Pospolita 39','Gdansk','80-022','11');
    Insert into BD_KLIENT (KLIENT_IMIE,KLIENT_NAZWISKO,KLIENT_ADRES,KLIENT_MIASTO,KOD_POCZTOWY,NR_WOJEWODZTWA) values ('Stanislaw','Szczygiel','Browarna 100','Torun','85-825','2');
    Insert into BD_KLIENT (KLIENT_IMIE,KLIENT_NAZWISKO,KLIENT_ADRES,KLIENT_MIASTO,KOD_POCZTOWY,NR_WOJEWODZTWA) values ('Dagmara','Pisklak','Cicha 45','Czestochowa','42-215','12');
    Insert into BD_KLIENT (KLIENT_IMIE,KLIENT_NAZWISKO,KLIENT_ADRES,KLIENT_MIASTO,KOD_POCZTOWY,NR_WOJEWODZTWA) values ('Henryk','Gall','Nieznana 99','Katowice','40-014','12');
    Insert into BD_KLIENT (KLIENT_IMIE,KLIENT_NAZWISKO,KLIENT_ADRES,KLIENT_MIASTO,KOD_POCZTOWY,NR_WOJEWODZTWA) values ('Lukasz','Stanislaw','Poczatkowa 33','Krasnik','23-200','3');
    
    Insert into BD_WOJEWODZTWA (NAZWA_WOJEWODZTWA) values ('dolnoslaskie');
    Insert into BD_WOJEWODZTWA (NAZWA_WOJEWODZTWA) values ('kujawsko-pomorskie');
    Insert into BD_WOJEWODZTWA (NAZWA_WOJEWODZTWA) values ('lubelskie');
    Insert into BD_WOJEWODZTWA (NAZWA_WOJEWODZTWA) values ('lubuskie');
    Insert into BD_WOJEWODZTWA (NAZWA_WOJEWODZTWA) values ('lodzkie');
    Insert into BD_WOJEWODZTWA (NAZWA_WOJEWODZTWA) values ('malopolskie');
    Insert into BD_WOJEWODZTWA (NAZWA_WOJEWODZTWA) values ('mazowieckie');
    Insert into BD_WOJEWODZTWA (NAZWA_WOJEWODZTWA) values ('opolskie');
    Insert into BD_WOJEWODZTWA (NAZWA_WOJEWODZTWA) values ('podkarpackie');
    Insert into BD_WOJEWODZTWA (NAZWA_WOJEWODZTWA) values ('podlaskie');
    Insert into BD_WOJEWODZTWA (NAZWA_WOJEWODZTWA) values ('pomorskie');
    Insert into BD_WOJEWODZTWA (NAZWA_WOJEWODZTWA) values ('slaskie');
    Insert into BD_WOJEWODZTWA (NAZWA_WOJEWODZTWA) values ('swietokrzyskie');
    Insert into BD_WOJEWODZTWA (NAZWA_WOJEWODZTWA) values ('warminsko-mazurskie');
    Insert into BD_WOJEWODZTWA (NAZWA_WOJEWODZTWA) values ('wielkopolskie');
    Insert into BD_WOJEWODZTWA (NAZWA_WOJEWODZTWA) values ('zachodniopomorskie');
  
  end dodaj_samochod_klient_wojewodztwa;

END GENEROWANIE_PROJEKT;