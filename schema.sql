CREATE TABLE IF NOT EXISTS users (
  id            VARCHAR(32)  NOT NULL PRIMARY KEY,
  nombre        VARCHAR(150) NOT NULL,
  email         VARCHAR(190) NOT NULL,
  password_hash VARCHAR(100) NOT NULL,
  rol           ENUM('admin','medico','paciente') NOT NULL,
  esp           VARCHAR(100) NOT NULL DEFAULT '',
  UNIQUE KEY uq_users_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Sin ON DELETE CASCADE: MySQL 8 no lo permite en columnas base de columnas generadas STORED,
-- las citas se borran explícitamente desde la aplicación antes de borrar usuarios.
-- MySQL no soporta índices únicos parciales (WHERE estado <> 'Cancelada').
-- Se emulan con columnas generadas que valen NULL cuando la cita está cancelada
-- (MySQL permite varios NULL en un índice UNIQUE).
CREATE TABLE IF NOT EXISTS citas (
  id            VARCHAR(32)  NOT NULL PRIMARY KEY,
  fecha         VARCHAR(10)  NOT NULL,
  hora          VARCHAR(10)  NOT NULL,
  pacienteId    VARCHAR(32)  NOT NULL,
  medicoId      VARCHAR(32)  NOT NULL,
  motivo        VARCHAR(500) NOT NULL,
  estado        ENUM('Pendiente','Confirmada','Atendida','Cancelada') NOT NULL,
  slot_medico   VARCHAR(80) GENERATED ALWAYS AS (IF(estado='Cancelada', NULL, CONCAT(medicoId,'|',fecha,'|',hora))) STORED,
  slot_paciente VARCHAR(80) GENERATED ALWAYS AS (IF(estado='Cancelada', NULL, CONCAT(pacienteId,'|',fecha,'|',hora))) STORED,
  UNIQUE KEY uq_medico_horario_activo (slot_medico),
  UNIQUE KEY uq_paciente_horario_activo (slot_paciente),
  KEY idx_citas_fecha (fecha, hora),
  CONSTRAINT fk_citas_paciente FOREIGN KEY (pacienteId) REFERENCES users(id),
  CONSTRAINT fk_citas_medico   FOREIGN KEY (medicoId)   REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
