/*
 * Copyright © 2016 Wind River Systems, Inc.
 *
 * The right to copy, distribute, modify, or otherwise make use of this
 * software may be licensed only pursuant to the terms of an applicable
 * Wind River license agreement.
 */

#ifndef SYSTEMD_UTIL_H
#define SYSTEMD_UTIL_H

#include <QtCore/QObject>
#include <QDBusInterface>
#include <QDebug>

class SystemdUnit: public QObject
{
	Q_OBJECT
	Q_PROPERTY(QString unitPath WRITE setUnitPath);
	Q_PROPERTY(uint pid READ getPid NOTIFY pidChanged);
public:
	explicit SystemdUnit(QObject *parent = 0);
	uint getPid() { return mPid; }
	void setUnitPath(const QString &unitFile);
	QString getUnitPath() { return mUnitPath; }
	QString getUnitFile() { return mUnitFile; }
	void notifyPidChanged(uint pid);
signals:
	void pidChanged(uint pid);
private:
	uint mPid;
	QString mUnitPath;
	QString mUnitFile;
};

class SystemdDbusClient: public QObject
{
	Q_OBJECT
public:
	explicit SystemdDbusClient(QObject *parent = 0);
	Q_INVOKABLE void startUnit(const QString &unitFile);
	Q_INVOKABLE void stopUnit(const QString &unitFile);
	Q_INVOKABLE void registerUnit(SystemdUnit* unit) { mUnitList.append(unit); }
	Q_INVOKABLE int getPidByUnitFile(const QString &unitFile);
private slots:
	void slotJobNew(uint, QDBusObjectPath, QString);
	void slotJobRemove(uint, QDBusObjectPath, QString, QString);
	void slotPropertiesChanged(QString, QMap<QString,QVariant>, QStringList);
private:
	void checkResult(uint pid, const QString &result);
	QString getUnitByPID(uint pid);
	QVector<SystemdUnit*> mUnitList;
};
#endif
