-- 더미 데이터 삭제
DELETE FROM Emergency_Request;
DELETE FROM Report;
DELETE FROM Sharing;
DELETE FROM Rating;
DELETE FROM Foods;
DELETE FROM Users;

COMMIT;

----------------------------------------------------------------------테이블 제거
DROP TABLE Sharing;
DROP TABLE Report;
DROP TABLE Emergency_Request;
DROP TABLE rating;
DROP TABLE Foods;
DROP TABLE Users;

---------------------------------------------------------------------테이블 만들기

CREATE TABLE Foods (
	food_id	NUMBER		NOT NULL,
	giver_id	NUMBER		NOT NULL,
	name	VARCHAR2(50)		NOT NULL,
	expiration_date	DATE		NULL,
	registration_date	DATE		NOT NULL,
	place	VARCHAR2(50)		NULL,
    amount number null,
	is_sharing	NUMBER(1)	DEFAULT 0	NOT NULL
);

CREATE TABLE Users (
	user_id	NUMBER		NOT NULL,
    id VARCHAR2(50)		NOT NULL,
	password	VARCHAR2(50)		NOT NULL,
	name	VARCHAR2(50)		NOT NULL,
	phone_number	VARCHAR2(50)		NOT NULL,
	address	VARCHAR2(50)		NOT NULL,
	is_vulnerable	NUMBER(1)	DEFAULT 0	NOT NULL,
	point	NUMBER	DEFAULT 0	NULL,
	badge	VARCHAR2(50)		NULL
);

CREATE TABLE rating (
    rating_id      NUMBER      NOT NULL,
    writer_id        NUMBER      NOT NULL,
    food_id        NUMBER      NOT NULL,
    score          NUMBER,
    damage_check   NUMBER(1),
    user_comment        VARCHAR2(50)
);

CREATE TABLE Sharing (
	sharing_id	NUMBER		NOT NULL,
	food_id	NUMBER		NOT NULL,
	receiver_id	NUMBER		NOT NULL,
	sharing_date	DATE		NOT NULL
);

CREATE TABLE Report (
	report_id	NUMBER		NOT NULL,
	report_user_id	NUMBER		NOT NULL,
	reported_user_id	NUMBER		NOT NULL,
	reason	VARCHAR2(50)		NULL,
	report_date	DATE		NOT NULL
);

CREATE TABLE Emergency_Request (
	request_id	NUMBER		NOT NULL,
	receiver_id	NUMBER		NOT NULL,
	food_name	VARCHAR2(50)		NOT NULL,
	place	VARCHAR2(50)		NULL,
	detail	VARCHAR2(50)		NULL,
	request_date	DATE		NOT NULL
);

ALTER TABLE Foods ADD CONSTRAINT PK_FOODS PRIMARY KEY (
	food_id
);

ALTER TABLE Users ADD CONSTRAINT PK_USER PRIMARY KEY (
	user_id
);

ALTER TABLE Rating ADD CONSTRAINT PK_RATING PRIMARY KEY (
	Rating_id
);

ALTER TABLE Sharing ADD CONSTRAINT PK_SHARING PRIMARY KEY (
	sharing_id
);

ALTER TABLE Report ADD CONSTRAINT PK_REPORT PRIMARY KEY (
	report_id
);

ALTER TABLE Emergency_Request ADD CONSTRAINT PK_EMERGENCY_REQUEST PRIMARY KEY (
	request_id
);

ALTER TABLE Foods ADD CONSTRAINT FK_User_TO_Foods FOREIGN KEY (
	giver_id
)
REFERENCES Users (
	user_id
);

ALTER TABLE Rating ADD CONSTRAINT FK_User_TO_Rating FOREIGN KEY (
	writer_id
)
REFERENCES Users (
	user_id
);

ALTER TABLE Rating ADD CONSTRAINT FK_Foods_TO_Rating FOREIGN KEY (
	food_id
)
REFERENCES Foods (
	food_id
);

ALTER TABLE Sharing ADD CONSTRAINT FK_Foods_TO_Sharing FOREIGN KEY (
	food_id
)
REFERENCES Foods (
	food_id
);


ALTER TABLE Sharing ADD CONSTRAINT FK_User_TO_Sharing_receiver_id FOREIGN KEY (
	receiver_id
)
REFERENCES Users (
	user_id
);

ALTER TABLE Report ADD CONSTRAINT FK_Users_TO_Report_1 FOREIGN KEY (
	report_user_id
)
REFERENCES Users (
	user_id
);

ALTER TABLE Report ADD CONSTRAINT FK_Users_TO_Report_2 FOREIGN KEY (
	reported_user_id
)
REFERENCES Users (
	user_id
);

ALTER TABLE Emergency_Request ADD CONSTRAINT FK_Users_TO_Emergency_Request FOREIGN KEY (
	receiver_id
)
REFERENCES Users (
	user_id
);


---------------------------------------------------------------------트리거 만들기

drop sequence user_id_sequence;
create sequence user_id_sequence;

CREATE OR REPLACE TRIGGER user_id_trigger
before insert on users
for each row
begin
    if :NEW.user_id IS NULL THEN
        :new.user_id := user_id_sequence.NEXTVAL;
    end if;
end;
/

drop sequence sharing_id_sequence;
create sequence sharing_id_sequence;

CREATE OR REPLACE TRIGGER sharing_id_trigger
BEFORE INSERT ON Sharing
FOR EACH ROW
BEGIN
    IF :NEW.sharing_id IS NULL THEN
        :NEW.sharing_id := sharing_id_sequence.NEXTVAL;
        :NEW.sharing_date := SYSDATE;
    END IF;
END;
/

drop sequence food_id_sequence;
create sequence food_id_sequence;

CREATE OR REPLACE TRIGGER food_id_trigger
before insert on foods
for each row
begin
    if :NEW.food_id IS NULL THEN
        :new.food_id := food_id_sequence.NEXTVAL;
        :new.REGISTRATION_DATE := sysdate;
        :new.IS_SHARING := 0;
    end if;
end;
/

CREATE OR REPLACE TRIGGER is_sharing_trigger
BEFORE UPDATE ON foods
FOR EACH ROW
BEGIN
    IF :NEW.amount = 0 THEN
        :NEW.is_sharing := 1;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER update_giver_point_trigger
AFTER UPDATE ON foods
FOR EACH ROW
BEGIN
    IF :OLD.amount > :NEW.amount THEN
        UPDATE users
        SET point = point + ((:OLD.amount - :NEW.amount) * 10)
        WHERE user_id = :NEW.giver_id;
    END IF;
END;
/


drop sequence report_id_sequence;
create sequence report_id_sequence;

CREATE OR REPLACE TRIGGER report_id_trigger
before insert on report
for each row
begin
    if :NEW.report_id IS NULL THEN
        :new.report_id := report_id_sequence.NEXTVAL;
        :new.report_DATE := sysdate;
    end if;
end;
/

drop sequence rating_id_sequence;
create sequence rating_id_sequence;

CREATE OR REPLACE TRIGGER rating_id_trigger
before insert on rating
for each row
begin
    if :NEW.rating_id IS NULL THEN
        :new.rating_id := rating_id_sequence.NEXTVAL;
    end if;
end;
/

drop sequence request_id_sequence;
create sequence request_id_sequence;

CREATE OR REPLACE TRIGGER request_id_trigger
before insert on emergency_request
for each row
begin
    if :NEW.request_id IS NULL THEN
        :new.request_id := request_id_sequence.NEXTVAL;
        :new.request_DATE := sysdate;
    end if;
end;
/

CREATE OR REPLACE TRIGGER user_badge_trigger
BEFORE UPDATE ON users
FOR EACH ROW
BEGIN
    IF :NEW.point > 500 THEN
        :NEW.badge := '숲 기부자';
    ELSIF :NEW.point > 400 THEN
        :NEW.badge := '나무 기부자';
    ELSIF :NEW.point > 300 THEN
        :NEW.badge := '가지 기부자';
    ELSIF :NEW.point > 200 THEN
        :NEW.badge := '잎새 기부자';
    ELSIF :NEW.point > 100 THEN
        :NEW.badge := '씨앗 기부자';
    ELSIF :NEW.point > 0 THEN
        :NEW.badge := '새싹 기부자';
    ELSE
        :NEW.badge := '없음';
    END IF;
END;
/
