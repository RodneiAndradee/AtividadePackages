CREATE OR REPLACE PACKAGE PKG_ALUNO AS
    PROCEDURE excluir_aluno(p_id_aluno IN NUMBER);
END PKG_ALUNO;
/

CREATE OR REPLACE PACKAGE BODY PKG_ALUNO AS
    PROCEDURE excluir_aluno(p_id_aluno IN NUMBER) IS
    BEGIN
        -- Excluindo as matrículas do aluno
        DELETE FROM matricula WHERE id_aluno = p_id_aluno;
        
        -- Excluindo o aluno
        DELETE FROM aluno WHERE id_aluno = p_id_aluno;
        
        COMMIT;
    END excluir_aluno;
END PKG_ALUNO;
/

CREATE OR REPLACE PACKAGE PKG_ALUNO AS
    CURSOR alunos_maiores_18 IS
        SELECT nome, data_nascimento
        FROM aluno
        WHERE TRUNC(SYSDATE) - data_nascimento > 18 * 365;
END PKG_ALUNO;
/

CREATE OR REPLACE PACKAGE PKG_ALUNO AS
    CURSOR alunos_por_curso(p_id_curso IN NUMBER) IS
        SELECT a.nome
        FROM aluno a
        JOIN matricula m ON a.id_aluno = m.id_aluno
        WHERE m.id_curso = p_id_curso;
END PKG_ALUNO;
/
CREATE OR REPLACE PACKAGE PKG_DISCIPLINA AS
    PROCEDURE cadastrar_disciplina(p_nome IN VARCHAR2, p_descricao IN VARCHAR2, p_carga_horaria IN NUMBER);
END PKG_DISCIPLINA;
/

CREATE OR REPLACE PACKAGE BODY PKG_DISCIPLINA AS
    PROCEDURE cadastrar_disciplina(p_nome IN VARCHAR2, p_descricao IN VARCHAR2, p_carga_horaria IN NUMBER) IS
    BEGIN
        INSERT INTO disciplina (nome, descricao, carga_horaria)
        VALUES (p_nome, p_descricao, p_carga_horaria);
        
        COMMIT;
    END cadastrar_disciplina;
END PKG_DISCIPLINA;
/
2. Cursor para total de alunos por disciplina:
Esse cursor retorna a quantidade de alunos matriculados em cada disciplina com mais de 10 alunos.

sql
Copiar código
CREATE OR REPLACE PACKAGE PKG_DISCIPLINA AS
    CURSOR total_alunos_por_disciplina IS
        SELECT d.nome, COUNT(m.id_aluno) AS total_alunos
        FROM disciplina d
        JOIN matricula m ON d.id_disciplina = m.id_disciplina
        GROUP BY d.nome
        HAVING COUNT(m.id_aluno) > 10;
END PKG_DISCIPLINA;
/

CREATE OR REPLACE PACKAGE PKG_DISCIPLINA AS
    CURSOR media_idade_por_disciplina(p_id_disciplina IN NUMBER) IS
        SELECT AVG(TRUNC(SYSDATE) - a.data_nascimento) / 365 AS media_idade
        FROM aluno a
        JOIN matricula m ON a.id_aluno = m.id_aluno
        WHERE m.id_disciplina = p_id_disciplina;
END PKG_DISCIPLINA;
/

CREATE OR REPLACE PACKAGE PKG_DISCIPLINA AS
    PROCEDURE listar_alunos_disciplina(p_id_disciplina IN NUMBER);
END PKG_DISCIPLINA;
/

CREATE OR REPLACE PACKAGE BODY PKG_DISCIPLINA AS
    PROCEDURE listar_alunos_disciplina(p_id_disciplina IN NUMBER) IS
    BEGIN
        FOR r IN (SELECT a.nome
                  FROM aluno a
                  JOIN matricula m ON a.id_aluno = m.id_aluno
                  WHERE m.id_disciplina = p_id_disciplina) 
        LOOP
            DBMS_OUTPUT.PUT_LINE(r.nome);
        END LOOP;
    END listar_alunos_disciplina;
END PKG_DISCIPLINA;
/

CREATE OR REPLACE PACKAGE PKG_PROFESSOR AS
    CURSOR total_turmas_por_professor IS
        SELECT p.nome, COUNT(t.id_turma) AS total_turmas
        FROM professor p
        JOIN turma t ON p.id_professor = t.id_professor
        GROUP BY p.nome
        HAVING COUNT(t.id_turma) > 1;
END PKG_PROFESSOR;
/

CREATE OR REPLACE PACKAGE PKG_PROFESSOR AS
    FUNCTION total_turmas_professor(p_id_professor IN NUMBER) RETURN NUMBER;
END PKG_PROFESSOR;
/

CREATE OR REPLACE PACKAGE BODY PKG_PROFESSOR AS
    FUNCTION total_turmas_professor(p_id_professor IN NUMBER) RETURN NUMBER IS
        v_total NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_total
        FROM turma
        WHERE id_professor = p_id_professor;
        
        RETURN v_total;
    END total_turmas_professor;
END PKG_PROFESSOR;
/

CREATE OR REPLACE PACKAGE PKG_PROFESSOR AS
    FUNCTION professor_de_disciplina(p_id_disciplina IN NUMBER) RETURN VARCHAR2;
END PKG_PROFESSOR;
/

CREATE OR REPLACE PACKAGE BODY PKG_PROFESSOR AS
    FUNCTION professor_de_disciplina(p_id_disciplina IN NUMBER) RETURN VARCHAR2 IS
        v_nome_professor VARCHAR2(100);
    BEGIN
        SELECT p.nome INTO v_nome_professor
        FROM professor p
        JOIN turma t ON p.id_professor = t.id_professor
        WHERE t.id_disciplina = p_id_disciplina
        FETCH FIRST 1 ROWS ONLY;
        
        RETURN v_nome_professor;
    END professor_de_disciplina;
END PKG_PROFESSOR;
/