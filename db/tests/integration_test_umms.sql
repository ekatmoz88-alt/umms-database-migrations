TRUNCATE TABLE ref_document_type, ref_document_reason, ref_department, gateway_dictionary_version CASCADE;
-- ============================================================================
-- ТЕСТОВЫЕ SQL-ЗАПРОСЫ (v3) ДЛЯ ПРОВЕРКИ СХЕМЫ БД ПРОЕКТА «ДЕШИФРАТОР»
-- Согласовано со схемой schema_umms_discriptor.sql
-- ============================================================================

-- ============================================================================
-- БЛОК 1. НАПОЛНЕНИЕ СПРАВОЧНИКОВ И ВСЕХ 4 КОНТРОЛЬНЫХ ДОСЬЕ ИЗ ПРОТОКОЛА
-- (Усенко Г.Л., Шумилов Э.А., Матюхин Э.Г., Прокофьев В.В.)
-- ============================================================================

INSERT INTO ref_document_type (id, name) VALUES
(1, 'Паспорт гражданина Российской Федерации'),
(2, 'Иностранный паспорт'),
(3, 'Свидетельство о рождении'),
(4, 'Загранпаспорт нового поколения (с биометрией)');
SELECT setval('ref_document_type_id_seq', 4, true);

INSERT INTO ref_document_reason (id, name) VALUES
(1, 'Приобретение гражданства Российской Федерации'),
(2, 'Утрата паспорта'),
(3, 'Непригодность к использованию в связи с порчей по вине владельца'),
(4, 'Достижение 45 лет');
SELECT setval('ref_document_reason_id_seq', 4, true);

INSERT INTO ref_department (id, code, name, region_code, region_name) VALUES
(1, '440-014', 'Отделение УФМС России по Костромской области в Мантуровском районе', '44', 'обл Костромская'),
(2, '440-029', 'ТП УФМС России по Костромской области в гор. Волгореченске', '44', 'обл Костромская'),
(3, '770-028', 'Отделение УФМС России по гор. Москве по району Северный', '77', 'г. Москва'),
(4, '232-049', 'ПВС ОВД Северского района', '23', 'край Краснодарский');
SELECT setval('ref_department_id_seq', 4, true);

-- Досье №1: Усенко Геннадий Леонидович
INSERT INTO person (id, external_ir_id, last_name, first_name, middle_name, gender, birth_date, birth_country, birth_place, citizenship, is_hidden, vbd_export_date, need_external_sync)
VALUES (1, 100501, 'Усенко', 'Геннадий', 'Леонидович', 'M', '1984-02-03', 'СССР', 'СССР, с. Дмитровка, Славянский район, Донецкая обл.', 'Россия', FALSE, '2014-11-11 10:00:00', FALSE);

INSERT INTO document (id, person_id, doc_type_id, series, number, issue_date, actual_issue_date, valid_from, department_id, dept_code, issued_by_full, application_place, reason_id, status, is_first_doc, has_mrz, mrz_line_1, mrz_line_2, executor_name)
VALUES
(101, 1, 2, 'ВК', '175070', '2005-09-16', '2005-09-16', '2005-09-16', NULL, NULL, 'Славянское РО УМВД Украины в Донецкой области', 'Славянское РО УМВД Украины', NULL, 'Недействительный', FALSE, FALSE, NULL, NULL, 'system'),
(102, 1, 1, '3412', '062867', '2013-04-10', '2013-04-12', '2013-04-12', 1, '440-014', 'Отделение УФМС России по Костромской области в Мантуровском районе', 'Отделение УФМС в Мантуровском р-не', 1, 'Действительный', TRUE, TRUE, 'PNRUSUSENKO<<GENNADIJ<LEONIDOVI3<<<<<<<<<<<<', '3410628674RUS8402035M<<<<<<<413041044001', 'system');

INSERT INTO document_operation (document_id, operation_date, operation_name) VALUES
(102, '2013-04-10', 'Подача заявления и принятие решения'),
(102, '2013-04-10', 'Печать и перевод на готовность'),
(102, '2013-04-12', 'Фактическая выдача паспорта гражданину');

INSERT INTO person_relation (person_id, relation_type, related_fio, related_gender, related_birth_date, act_number, issued_by, date_from) VALUES
(1, 'Ребёнок', 'Усенко Арсений Геннадьевич', 'M', '2006-04-14', NULL, NULL, '2006-04-14'),
(1, 'Ребёнок', 'Усенко Захар Геннадьевич', 'M', '2007-10-19', NULL, NULL, '2007-10-19'),
(1, 'Супруг(а)', 'Северова Инга Петровна', 'F', '1976-05-12', '102', 'Отдел ЗАГС Краматорского ГУЮ в Донецкой обл.', '2011-03-09');

INSERT INTO address_registration (person_id, reg_type, date_from, date_to, country, region, district, city, house, full_address) VALUES
(1, 'По месту жительства', '2013-04-12', NULL, 'Россия', 'Костромская обл.', 'Мантуровский р-н', 'д. Кириллово', '13', 'Россия, Костромская обл., Мантуровский р-н, д. Кириллово, д. 13');

INSERT INTO dossier_case (person_id, case_number, open_date, close_date, status, status_date, case_type, is_applicant, applicant_fio, person_role) VALUES
(1, '440-01403413005388', '2013-04-10', '2013-04-12', 'Закрыто', '2013-04-12', 'Выдача/замена паспорта гражданина РФ', TRUE, 'Усенко Геннадий Леонидович', 'Заявитель');

-- Досье №2: Шумилов Эдуард Александрович (сценарий №2 + откат п. 2.4.3 ТЗ)
INSERT INTO person (id, external_ir_id, last_name, first_name, middle_name, gender, birth_date, birth_country, birth_place, citizenship, inn, military_duty_info, is_hidden, vbd_export_date, need_external_sync)
VALUES (2, 139146, 'Шумилов', 'Эдуард', 'Александрович', 'M', '1973-12-07', 'СССР', 'СССР, гор. Владимир', 'Россия', '440100000001', 'Военнообязанный', FALSE, '2014-11-19 15:05:00', TRUE);

INSERT INTO document (id, person_id, doc_type_id, series, number, issue_date, actual_issue_date, valid_from, valid_to, department_id, dept_code, issued_by_full, application_place, reason_id, status, is_first_doc, has_mrz, mrz_line_1, mrz_line_2, executor_name)
VALUES
(201, 2, 1, '3403', '595440', '2003-09-16', '2003-09-16', '2003-09-16', '2013-06-27', 2, '442-029', 'ОВД г. Волгореченска Костромской области', 'ОВД г. Волгореченска', NULL, 'Утерян', TRUE, FALSE, NULL, NULL, 'system'),
(202, 2, 1, '3413', '094265', '2013-06-27', '2013-07-01', '2013-07-01', '2014-11-19', 2, '440-029', 'ТП УФМС России по Костромской области в гор. Волгореченске', 'ТП УФМС в гор. Волгореченске', 2, 'Недействительный', FALSE, TRUE, 'PNRUS4UMILOV<<6DUARD<ALEKSANDROVI3<<<<<<<<<<', '3410942652RUS7312070M<<<<<<<313062744002', 'system'),
(203, 2, 1, '4008', '483778', '2014-11-19', '2014-11-19', '2014-11-19', NULL, 3, '770-028', 'Отделение УФМС России по гор. Москве по району Северный', 'Отделение УФМС по району Северный', 3, 'Действительный', FALSE, TRUE, 'PNRUS4UMILOV<<6DUARD<ALEKSANDROVI3<<<<<<<<<<', '4004837780RUS7312070M<<<<<<<814111977002', 'admin');

-- Намеренный дубль адреса (воспроизведение дефекта BUG-05 из ВБД)
INSERT INTO address_registration (person_id, reg_type, date_from, date_to, country, region, city, street, house, flat, full_address) VALUES
(2, 'По месту жительства', '1992-12-02', '2013-11-11', 'Россия', 'обл Костромская', 'г Волгореченск', 'ул Зеленова', '1/28', '47', '156901 Россия, г Волгореченск, обл Костромская, ул Зеленова, дом 1/28, кв. 47'),
(2, 'По месту жительства', '1992-12-02', '2013-11-11', 'Россия', 'обл Костромская', 'г Волгореченск', 'ул Зеленова', '1/28', '47', '156901 Россия, г Волгореченск, обл Костромская, ул Зеленова, дом 1/28, кв. 47');

INSERT INTO dossier_signal (person_id, entity_type, entity_id, period_from, signal_type, message, content) VALUES
(2, 'DOCUMENT', 201, '2013-06-27', 'Утрата документа', 'Паспорт 3403 595440 числится утраченным', 'Заявление об утрате паспорта от 27.06.2013');

-- Досье №3: Матюхин Эрик Глебович (создано через Сценарий №3)
INSERT INTO person (id, external_ir_id, last_name, first_name, middle_name, gender, birth_date, birth_country, birth_place, citizenship, inn, is_hidden, vbd_export_date, need_external_sync)
VALUES (3, 220582, 'Матюхин', 'Эрик', 'Глебович', 'M', '1980-11-13', 'Россия', 'Россия, г. Архангельск', 'Россия', '000000000000', FALSE, '2014-11-19 16:37:00', FALSE);

INSERT INTO document (id, person_id, doc_type_id, series, number, issue_date, actual_issue_date, valid_from, valid_to, department_id, dept_code, issued_by_full, application_place, reason_id, status, is_first_doc, has_mrz, executor_name)
VALUES
(301, 3, 1, '3465', '678045', '2012-11-19', '2012-11-19', '2012-11-19', '2014-11-19', 4, '232-049', 'ПВС ОВД Северского района', 'По месту жительства', NULL, 'Недействительный', TRUE, TRUE, 'system system system'),
(302, 3, 1, '3412', '123478', '2014-11-19', '2014-11-19', '2014-11-19', NULL, 3, '770-028', 'Отделение УФМС России по гор. Москве по району Северный', 'По месту жительства', 3, 'Действительный', FALSE, TRUE, 'system system system');

INSERT INTO address_registration (person_id, reg_type, date_from, country, region, city, street, house, flat, full_address) VALUES
(3, 'По месту жительства', '2014-11-18', 'Россия', 'обл Волгоградская', 'г Фролово', 'пер Литейная', '123', '2', '403531 Россия, г Фролово, обл Волгоградская, пер Литейная, дом 123, кв. 2');

-- Досье №4: Прокофьев Валерий Владимирович (Сценарий №4 — восстановление без создания нового документа)
INSERT INTO person (id, external_ir_id, last_name, first_name, middle_name, gender, birth_date, birth_country, birth_place, citizenship, is_hidden, vbd_export_date, need_external_sync)
VALUES (4, 145890, 'Прокофьев', 'Валерий', 'Владимирович', 'M', '1968-03-06', 'СССР', 'СССР, дер. Петровка Красносельского района Костромской области', 'Россия', FALSE, '2014-11-19 17:21:00', FALSE);

INSERT INTO document (id, person_id, doc_type_id, series, number, issue_date, actual_issue_date, valid_from, department_id, dept_code, issued_by_full, reason_id, status, is_first_doc, has_mrz, executor_name)
VALUES
(401, 4, 1, '3402', '324410', '2002-07-04', '2002-07-04', '2002-07-04', 2, '440-029', 'ТП УФМС России по Костромской области в гор. Волгореченске', NULL, 'Недействительный', TRUE, FALSE, 'system'),
(402, 4, 1, '3413', '094180', '2013-05-27', '2013-06-11', '2013-06-11', 2, '440-029', 'ТП УФМС России по Костромской области в гор. Волгореченске', 4, 'Действительный', FALSE, TRUE, 'system');

SELECT setval('person_id_seq', 4, true);
SELECT setval('document_id_seq', 402, true);

-- Штампы страниц 5–19 паспорта РФ (п. 1.5.3 ТЗ)
INSERT INTO passport_stamp_registration (document_id, page_number, orientation, form_code, stamp_date, addr_country, addr_region, addr_city, addr_street, addr_house, addr_flat, department_name, dept_code)
VALUES (202, 5, 'LEFT', '5П', '2013-07-01', 'Россия', 'обл Костромская', 'г Волгореченск', 'ул Зеленова', '1/28', '47', 'ТП УФМС России по Костромской области в гор. Волгореченске', '440-029');

INSERT INTO passport_stamp_military (document_id, page_number, form_code, stamp_date, dept_code)
VALUES (202, 13, '11П', '2013-07-01', '440-029');

INSERT INTO passport_stamp_marriage (document_id, page_number, orientation, form_code, event_date, spouse_fio, spouse_birth_date, zags_name, act_number, dept_code)
VALUES (202, 14, 'LEFT', '13П', '2012-02-25', 'Носкова Ольга Борисовна', '1967-05-26', 'Отдел ЗАГС г. Волгореченска', '28', '440-029');

INSERT INTO passport_stamp_children (document_id, page_number, child_fio, child_gender, child_birth_date)
VALUES (202, 17, 'Шумилов Михаил Эдуардович', 'M', '2003-07-22');

INSERT INTO passport_stamp_prev_docs (document_id, page_number, form_code, prev_doc_series, prev_doc_number, dept_code, issue_date)
VALUES (202, 19, '16П', '3403', '595440', '442-029', '2003-09-16');

-- Состояние печати страниц и журнал израсходованных бланков (пп. 1.5.2, 1.5.4 ТЗ)
INSERT INTO print_page_state (document_id, page_number, print_count, is_fixed, fixed_at) VALUES
(202, 2, 1, TRUE, '2013-07-01 12:00:00'),
(202, 3, 2, FALSE, NULL);

INSERT INTO used_blank_journal (document_id, person_id, blank_series, blank_number, operator_login, is_spoiled, comment) VALUES
(202, 2, '3413', '094265', 'admin', FALSE, 'Успешная печать бланка паспорта РФ'),
(302, 3, '3412', '123478', 'admin', FALSE, 'Печать бланка по Сценарию №3');

-- Задания обмена, журнал сценариев, полный слепок состояния ВБД и аудит
INSERT INTO export_batch (id, task_number, approval_date, comment, export_date, import_date, processing_stage) VALUES
(1, '1973', '2014-11-19 15:10:00', 'abr1', '2014-11-19 15:10:00', '2014-11-19 15:18:00', 3),
(2, '34', '2014-11-19 17:23:00', 'abr2', '2014-11-19 17:23:00', '2014-11-19 17:24:00', 5);
SELECT setval('export_batch_id_seq', 2, true);

INSERT INTO export_batch_person (batch_id, person_id) VALUES (1, 2), (2, 4);

INSERT INTO edit_scenario_log (person_id, scenario_code, status, is_cancelled, is_exported_to_vbd, user_login) VALUES
(2, 'SCENARIO_2', 'Импорт редактируемых или новых досье на БД ИР', FALSE, TRUE, 'admin'),
(3, 'SCENARIO_3', 'Создан', FALSE, TRUE, 'admin'),
(4, 'SCENARIO_4', 'Восстановление информации о человеке без создания нового документа', FALSE, TRUE, 'admin');

-- Полный снимок исходного состояния досье Шумилова Э.А. до применения Сценария №2
INSERT INTO vbd_dossier_snapshot (id, person_id, external_ir_id, vbd_row_version, snapshot_payload, loaded_at, expires_at, is_reverted)
VALUES (
    1,
    2,
    139146,
    'vbd_hash_139146_001',
    '{
        "person": {
            "last_name": "Шумилов",
            "first_name": "Эдуард",
            "middle_name": "Александрович",
            "gender": "M",
            "birth_date": "1973-12-07",
            "death_date": null,
            "birth_country": "СССР",
            "birth_place": "СССР, гор. Владимир",
            "citizenship": "Россия",
            "inn": "440100000001",
            "military_duty_info": "Военнообязанный",
            "is_hidden": false,
            "need_external_sync": false
        },
        "created_document_ids": [203],
        "documents": [
            {
                "id": 201,
                "doc_type_id": 1,
                "series": "3403",
                "number": "595440",
                "issue_date": "2003-09-16",
                "actual_issue_date": "2003-09-16",
                "valid_from": "2003-09-16",
                "valid_to": "2013-06-27",
                "department_id": 2,
                "dept_code": "442-029",
                "issued_by_full": "ОВД г. Волгореченска Костромской области",
                "application_place": "ОВД г. Волгореченска",
                "reason_id": null,
                "status": "Утерян",
                "is_first_doc": true,
                "has_mrz": false,
                "executor_name": "system"
            },
            {
                "id": 202,
                "doc_type_id": 1,
                "series": "3413",
                "number": "094265",
                "issue_date": "2013-06-27",
                "actual_issue_date": "2013-07-01",
                "valid_from": "2013-07-01",
                "valid_to": null,
                "department_id": 2,
                "dept_code": "440-029",
                "issued_by_full": "ТП УФМС России по Костромской области в гор. Волгореченске",
                "application_place": "ТП УФМС в гор. Волгореченске",
                "reason_id": 2,
                "status": "Недействительный",
                "is_first_doc": false,
                "has_mrz": true,
                "executor_name": "system"
            }
        ]
    }'::JSONB,
    '2014-11-19 15:05:00',
    '2014-11-26 15:05:00',
    FALSE
);
SELECT setval('vbd_dossier_snapshot_id_seq', 1, true);

INSERT INTO audit_log (event_time, user_login, action_type, details) VALUES
('2014-11-19 15:00:00', 'admin', 'LOGIN_OK', '{"module": "ModuleStationary"}'::JSONB),
('2014-11-19 15:43:00', 'admin', 'EDIT', '{"person_id": 2, "scenario": "SCENARIO_2"}'::JSONB),
('2014-11-19 15:52:00', 'admin', 'SYNC', '{"person_id": "2", "direction": "MM_TO_VBD"}'::JSONB);

INSERT INTO gateway_connection_log (mm_client_ip, mm_login, is_auth_success, operation_type, records_count)
VALUES ('192.168.192.105', 'mm_operator1', TRUE, 'SEARCH', 4);

INSERT INTO gateway_dictionary_version (dict_code, version_number) VALUES
('DOC_TYPES', 1), ('DOC_REASONS', 1), ('DEPARTMENTS', 1);


-- ============================================================================
-- БЛОК 2. ПРОВЕРОЧНЫЕ SELECT-ЗАПРОСЫ (ПОИСК, ПЕЧАТЬ, КОНТРОЛЬ ДУБЛЕЙ)
-- ============================================================================

-- 2.1. Поиск лиц по критериям п. 2.2.1 ТЗ (диапазон ДР + пол + фильтр по региону документа)
SELECT DISTINCT p.id, p.last_name, p.first_name, p.middle_name, p.birth_date, p.is_hidden
FROM person p
JOIN document d ON d.person_id = p.id
LEFT JOIN ref_department dep ON dep.id = d.department_id
WHERE p.birth_date BETWEEN DATE '1965-01-01' AND DATE '1985-12-31'
  AND p.gender = 'M'
  AND (dep.region_code = '44' OR dep.region_code = '77')
ORDER BY p.last_name;

-- 2.2. Полная карточка штампов страниц 5–19 для печати документа 202 (п. 1.5.3 ТЗ)
SELECT
    d.series || ' ' || d.number AS passport,
    (SELECT COUNT(*) FROM passport_stamp_registration r WHERE r.document_id = d.id) AS reg_stamps_cnt,
    (SELECT COUNT(*) FROM passport_stamp_military m WHERE m.document_id = d.id) AS mil_stamps_cnt,
    (SELECT COUNT(*) FROM passport_stamp_marriage mr WHERE mr.document_id = d.id) AS marriage_stamps_cnt,
    (SELECT COUNT(*) FROM passport_stamp_children c WHERE c.document_id = d.id) AS children_rows_cnt,
    (SELECT COUNT(*) FROM passport_stamp_prev_docs pv WHERE pv.document_id = d.id) AS prev_docs_stamps_cnt
FROM document d
WHERE d.id = 202;

-- 2.3. Контроль статуса фиксации страниц печати (п. 1.5.2 ТЗ)
SELECT document_id, page_number, print_count, is_fixed
FROM print_page_state
WHERE document_id = 202
ORDER BY page_number;

-- 2.4. Выявление дублирующихся регистраций в БД (контроль дефекта BUG-05)
SELECT person_id, reg_type, date_from, date_to, full_address, COUNT(*) AS dup_count
FROM address_registration
GROUP BY person_id, reg_type, date_from, date_to, full_address
HAVING COUNT(*) > 1;


-- ============================================================================
-- БЛОК 3. БИЗНЕС-СЦЕНАРИЙ ОТКАТА ВБД (UPDATE / DELETE ПО п. 2.4.3 ТЗ)
-- Полное восстановление состояния person и document по конкретному snapshot_id
-- ============================================================================

DO $$
DECLARE
    v_person_id BIGINT;
    v_snapshot_id BIGINT;
    v_snapshot_loaded_at TIMESTAMP;
    v_payload JSONB;
    v_has_foreign_ops BOOLEAN;
    v_deleted_docs INT;
    v_updated_person INT;
    v_restored_docs INT;
    v_expected_docs INT;
    v_updated_scenario INT;
    v_updated_snapshot INT;
    v_doc_rec JSONB;
BEGIN
    -- 1. Определение субъекта и блокировка конкретного последнего активного снимка
    SELECT id INTO v_person_id
    FROM person
    WHERE last_name = 'Шумилов' AND first_name = 'Эдуард' AND birth_date = DATE '1973-12-07';

    IF v_person_id IS NULL THEN
        RAISE EXCEPTION 'Контрольное досье для отката не найдено';
    END IF;

    SELECT id, loaded_at, snapshot_payload
    INTO v_snapshot_id, v_snapshot_loaded_at, v_payload
    FROM vbd_dossier_snapshot
    WHERE person_id = v_person_id AND is_reverted = FALSE
    ORDER BY loaded_at DESC, id DESC
    LIMIT 1
    FOR UPDATE;

    IF v_snapshot_id IS NULL THEN
        RAISE EXCEPTION 'Активный снимок состояния ВБД для отката не найден (п. 2.4.3 ТЗ)';
    END IF;

    -- 2. Безопасная проверка audit_log на сторонние операции (через CASE для защиты от ошибок типов JSONB)
    SELECT EXISTS (
        SELECT 1
        FROM audit_log
        WHERE event_time > v_snapshot_loaded_at
          AND action_type NOT IN ('SYNC', 'EDIT', 'LOGIN_OK')
          AND CASE
                WHEN jsonb_typeof(details->'person_id') = 'number'
                    THEN (details->>'person_id')::BIGINT
                WHEN jsonb_typeof(details->'person_id') = 'string'
                     AND (details->>'person_id') ~ '^[0-9]+$'
                    THEN (details->>'person_id')::BIGINT
                ELSE NULL
              END = v_person_id
    ) INTO v_has_foreign_ops;

    IF v_has_foreign_ops THEN
        RAISE EXCEPTION 'Откат заблокирован (п. 2.4.3 ТЗ): с объектом % производились сторонние операции', v_person_id;
    END IF;

    -- 3. DELETE: удаление всех документов, созданных в рамках отменяемого сценария
    DELETE FROM document
    WHERE person_id = v_person_id
      AND id IN (
          SELECT (elem.value)::BIGINT
          FROM jsonb_array_elements_text(v_payload->'created_document_ids') AS elem(value)
      );
    GET DIAGNOSTICS v_deleted_docs = ROW_COUNT;

    IF v_deleted_docs <> jsonb_array_length(v_payload->'created_document_ids') THEN
        RAISE EXCEPTION 'Ошибка отката: ожидалось удаление % документов, фактически удалено %',
            jsonb_array_length(v_payload->'created_document_ids'), v_deleted_docs;
    END IF;

    -- 4. UPDATE (person): полное восстановление всех сохраненных атрибутов карточки ФЛ из snapshot_payload
    UPDATE person
    SET last_name          = v_payload->'person'->>'last_name',
        first_name         = v_payload->'person'->>'first_name',
        middle_name        = v_payload->'person'->>'middle_name',
        gender             = v_payload->'person'->>'gender',
        birth_date         = (v_payload->'person'->>'birth_date')::DATE,
        death_date         = (v_payload->'person'->>'death_date')::DATE,
        birth_country      = v_payload->'person'->>'birth_country',
        birth_place        = v_payload->'person'->>'birth_place',
        citizenship        = v_payload->'person'->>'citizenship',
        inn                = v_payload->'person'->>'inn',
        military_duty_info = v_payload->'person'->>'military_duty_info',
        is_hidden          = (v_payload->'person'->>'is_hidden')::BOOLEAN,
        need_external_sync = (v_payload->'person'->>'need_external_sync')::BOOLEAN
    WHERE id = v_person_id;
    GET DIAGNOSTICS v_updated_person = ROW_COUNT;

    IF v_updated_person <> 1 THEN
        RAISE EXCEPTION 'Ошибка отката: не удалось восстановить запись person (id=%)', v_person_id;
    END IF;

    -- 5. UPDATE (document): полное восстановление атрибутов каждого исходного документа из массива documents
    v_restored_docs := 0;
    v_expected_docs := jsonb_array_length(v_payload->'documents');

    FOR v_doc_rec IN SELECT * FROM jsonb_array_elements(v_payload->'documents')
    LOOP
        UPDATE document
        SET doc_type_id       = (v_doc_rec->>'doc_type_id')::INT,
            series            = v_doc_rec->>'series',
            number            = v_doc_rec->>'number',
            issue_date        = (v_doc_rec->>'issue_date')::DATE,
            actual_issue_date = (v_doc_rec->>'actual_issue_date')::DATE,
            valid_from        = (v_doc_rec->>'valid_from')::DATE,
            valid_to          = (v_doc_rec->>'valid_to')::DATE,
            department_id     = (v_doc_rec->>'department_id')::INT,
            dept_code         = v_doc_rec->>'dept_code',
            issued_by_full    = v_doc_rec->>'issued_by_full',
            application_place = v_doc_rec->>'application_place',
            reason_id         = (v_doc_rec->>'reason_id')::INT,
            status            = v_doc_rec->>'status',
            is_first_doc      = (v_doc_rec->>'is_first_doc')::BOOLEAN,
            has_mrz           = (v_doc_rec->>'has_mrz')::BOOLEAN,
            executor_name     = v_doc_rec->>'executor_name'
        WHERE id = (v_doc_rec->>'id')::BIGINT
          AND person_id = v_person_id;

        IF FOUND THEN
            v_restored_docs := v_restored_docs + 1;
        END IF;
    END LOOP;

    IF v_restored_docs <> v_expected_docs THEN
        RAISE EXCEPTION 'Ошибка отката: восстановлено % из % исходных документов', v_restored_docs, v_expected_docs;
    END IF;

    -- 6. Обновление статуса сценария и строгая проверка ROW_COUNT
    UPDATE edit_scenario_log
    SET is_cancelled = TRUE,
        status = 'Восстановление ранее выгруженных заданий в БД ИР (откат п. 2.4.3)'
    WHERE person_id = v_person_id
      AND scenario_code = 'SCENARIO_2'
      AND is_cancelled = FALSE;
    GET DIAGNOSTICS v_updated_scenario = ROW_COUNT;

    IF v_updated_scenario <> 1 THEN
        RAISE EXCEPTION 'Ошибка отката: ожидалось обновление 1 записи в edit_scenario_log, обновлено %', v_updated_scenario;
    END IF;

    -- 7. Закрытие строго выбранного снимка (по конкретному v_snapshot_id)
    UPDATE vbd_dossier_snapshot
    SET is_reverted = TRUE,
        reverted_at = NOW()
    WHERE id = v_snapshot_id
      AND is_reverted = FALSE;
    GET DIAGNOSTICS v_updated_snapshot = ROW_COUNT;

    IF v_updated_snapshot <> 1 THEN
        RAISE EXCEPTION 'Ошибка отката: не удалось закрыть снимок vbd_dossier_snapshot (id=%)', v_snapshot_id;
    END IF;

    -- 8. Запись события отката в журнал аудита
    INSERT INTO audit_log (user_login, action_type, details)
    VALUES (
        'admin',
        'ROLLBACK_VBD',
        jsonb_build_object(
            'snapshot_id', v_snapshot_id,
            'person_id', v_person_id,
            'scenario', 'SCENARIO_2',
            'deleted_docs', v_deleted_docs,
            'restored_docs', v_restored_docs
        )
    );

    RAISE NOTICE 'Бизнес-откат по snapshot_id=% успешно выполнен (удалено док.: %, восстановлено док.: %)',
        v_snapshot_id, v_deleted_docs, v_restored_docs;
END $$;

-- Контрольная проверка состояния после фиксации бизнес-отката
SELECT p.id, p.last_name, p.need_external_sync, d.id AS doc_id, d.series, d.number, d.status, d.valid_to, s.is_reverted
FROM person p
JOIN document d ON d.person_id = p.id
JOIN vbd_dossier_snapshot s ON s.person_id = p.id
WHERE p.id = 2
ORDER BY d.id;


-- ============================================================================
-- БЛОК 4. ИСПОЛНЯЕМЫЕ НЕГАТИВНЫЕ ТЕСТЫ ОГРАНИЧЕНИЙ ФЛК (CHECK / UNIQUE)
-- Автоматически проверяют блокировку некорректных данных без прерывания скрипта
-- ============================================================================

DO $$
BEGIN
    -- Тест 4.1: Недопустимые символы в серии бланка паспорта (п. 1.5.4 / 3.4.4 ТЗ)
    BEGIN
        INSERT INTO used_blank_journal (document_id, person_id, blank_series, blank_number, operator_login)
        VALUES (202, 2, '34AB', '123456', 'admin');
        RAISE EXCEPTION 'ОШИБКА ФЛК: БД пропустила нецифровую серию бланка 34AB!';
    EXCEPTION
        WHEN check_violation THEN
            RAISE NOTICE 'OK [Негативный тест 4.1]: ФЛК серии бланка сработал корректно (check_violation)';
    END;

    -- Тест 4.2: Неверная длина номера бланка (п. 1.5.4 / 3.4.4 ТЗ)
    BEGIN
        INSERT INTO used_blank_journal (document_id, person_id, blank_series, blank_number, operator_login)
        VALUES (202, 2, '3413', '12345', 'admin');
        RAISE EXCEPTION 'ОШИБКА ФЛК: БД пропустила номер бланка из 5 цифр!';
    EXCEPTION
        WHEN check_violation THEN
            RAISE NOTICE 'OK [Негативный тест 4.2]: ФЛК размерности номера бланка сработал корректно (check_violation)';
    END;

    -- Тест 4.3: Недопустимый номер страницы для штампа регистрации (допустимы только 5..12)
    BEGIN
        INSERT INTO passport_stamp_registration (document_id, page_number, orientation, form_code, stamp_date, department_name, dept_code)
        VALUES (202, 99, 'LEFT', '5П', '2014-01-01', 'Тестовое подразделение', '440-001');
        RAISE EXCEPTION 'ОШИБКА ФЛК: БД пропустила недопустимый номер страницы 99!';
    EXCEPTION
        WHEN check_violation THEN
            RAISE NOTICE 'OK [Негативный тест 4.3]: ФЛК номера страницы штампа сработал корректно (check_violation)';
    END;

    -- Тест 4.4: Попытка включить МЧЗ для паспорта РФ, выданного до 01.07.2011 (п. 1.5.1 / 3.4.1 ТЗ)
    BEGIN
        INSERT INTO document (person_id, doc_type_id, series, number, issue_date, status, has_mrz)
        VALUES (2, 1, '3405', '111222', DATE '2010-05-15', 'Действительный', TRUE);
        RAISE EXCEPTION 'ОШИБКА ФЛК: БД разрешила МЧЗ для паспорта с датой выдачи до 01.07.2011!';
    EXCEPTION
        WHEN check_violation THEN
            RAISE NOTICE 'OK [Негативный тест 4.4]: ФЛК даты выдачи МЧЗ (>= 01.07.2011) сработал корректно';
    END;

    -- Тест 4.5: Повторное использование уже израсходованного бланка (UNIQUE blank_series, blank_number)
    BEGIN
        INSERT INTO used_blank_journal (document_id, person_id, blank_series, blank_number, operator_login)
        VALUES (202, 2, '3413', '094265', 'admin');
        RAISE EXCEPTION 'ОШИБКА ФЛК: БД разрешила повторную регистрацию того же бланка!';
    EXCEPTION
        WHEN unique_violation THEN
            RAISE NOTICE 'OK [Негативный тест 4.5]: Контроль уникальности бланка сработал корректно (unique_violation)';
    END;
END $$;

DO $$
BEGIN
    INSERT INTO passport_stamp_military (document_id, page_number, stamp_date, dept_code) VALUES (202, 99, '2024-01-01', '770-001');
    RAISE EXCEPTION 'ОШИБКА ФЛК: страница 99 принята';
EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'OK [Негативный тест 4.3б]: ФЛК воинского штампа сработал корректно';
END $$;
