#!/usr/bin/ruby

MAX_ASSET = 13
MAX_CATEGORY = 5

def initTable
    puts "DROP TABLE Transactions;"
    puts "DROP TABLE Assets;"
    puts "DROP TABLE Categories;"
    puts "CREATE TABLE Transactions (key INTEGER PRIMARY KEY,asset INTEGER,dst_asset INTEGER,date DATE,type INTEGER,category INTEGER,value REAL,description TEXT,memo TEXT,identifier TEXT);"
    puts "CREATE TABLE Assets (key INTEGER PRIMARY KEY,name TEXT,type INTEGER,initialBalance REAL,sorder INTEGER,identifier TEXT);"
    puts "CREATE TABLE Categories (key INTEGER PRIMARY KEY,name TEXT,sorder INTEGER);"
end

def initAssets
    puts <<EOF
INSERT INTO "Assets" VALUES(1,'現金',0,0.0,99999,'');
INSERT INTO "Assets" VALUES(2,'A銀行',1,0.0,99999,'');
INSERT INTO "Assets" VALUES(3,'B銀行',1,0.0,99999,'');
INSERT INTO "Assets" VALUES(4,'C銀行',1,0.0,99999,'');
INSERT INTO "Assets" VALUES(5,'D銀行',1,0.0,99999,'');
INSERT INTO "Assets" VALUES(6,'E銀行',1,0.0,99999,'');
INSERT INTO "Assets" VALUES(7,'F銀行',1,0.0,99999,'');
INSERT INTO "Assets" VALUES(8,'Gカード',2,0.0,99999,'');
INSERT INTO "Assets" VALUES(9,'Hカード',2,0.0,99999,'');
INSERT INTO "Assets" VALUES(10,'Iカード',2,0.0,99999,'');
INSERT INTO "Assets" VALUES(11,'Jカード',2,0.0,99999,'');
INSERT INTO "Assets" VALUES(12,'Kカード',2,0.0,99999,'');
INSERT INTO "Assets" VALUES(13,'Lカード',2,0.0,99999,'');
EOF
end

def initCategories
    puts <<EOF
INSERT INTO "Categories" VALUES(1,'食費',0);
INSERT INTO "Categories" VALUES(2,'交通費',1);
INSERT INTO "Categories" VALUES(3,'医療費',2);
EOF
end

def createTransactions
    pkey = 1
    asset = 1
    year = 2010
    month = 1
    day = 1
    hour = 12
    min = 0
    sec = 0

    while (pkey < 5000)

#        d = sprintf("%04d%02d%02d%02d%02d%02d", year, month, day, hour, min, sec);
        d = sprintf("%04d%02d%02d%02d%02d", year, month, day, hour, min);
        type = pkey % 3 + 1
        asset = pkey % MAX_ASSET + 1
        cat = pkey % MAX_CATEGORY + 1

	sec += 1;
	sec = 0 if (sec >= 60);

        min += 1
        min = 0 if (min >= 60);

        hour += 1
        if (hour >= 24)
            hour = 0
            day += 1
            if (day >= 29)
                day = 1
                month += 1
                if (month >= 12)
		    month = 1
                    year += 1
                end
            end
        end

	desc = "Desc:#{pkey}"
	memo = "Transaction has #{pkey} primary key."
        #puts "INSERT INTO \"Transactions\" VALUES(#{pkey},#{asset},-1,#{d},#{type},#{cat},#{pkey*10.0},'#{desc}','#{memo}','');"
        puts "INSERT INTO \"Transactions\" VALUES(#{pkey},#{asset},-1,#{d},#{type},#{cat},1,'#{desc}','#{memo}','');"

        pkey += 1
    end
end

puts "-- CashFlow Backup Format rev. 3 --"
#puts "BEGIN TRANSACTION;"
initTable
initAssets
initCategories
createTransactions
#puts "COMMIT;"

