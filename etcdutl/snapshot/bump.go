package snapshot

import (
	"go.etcd.io/etcd/api/v3/mvccpb"
	"go.etcd.io/etcd/server/v3/mvcc/backend"
	"go.etcd.io/etcd/server/v3/mvcc/buckets"
	"go.uber.org/zap"
)

// revBump increases the revision, modrevision, and version of every key to force watchers to resync.
//
// In order to ensure that watchers don't have a revision that's higher than the restored revision,
// 'amount' should be a very large number, > 1_000_000.
//
// Compaction should be run after this to further help invalidate watcher caches.
func (s *v3Manager) revBump(amount int64) error {
	// Don't do anything if there's nothing to do
	if amount == 0 {
		s.lg.Info("skipping revision bump")
		return nil
	}

	s.lg.Info("starting revision bump", zap.Int64("bump-amount", amount))
	defer s.lg.Info("finished revision bump")

	be := backend.NewDefaultBackend(s.outDbPath())
	defer be.Close()

	tx := be.BatchTx()
	tx.LockInsideApply()
	defer tx.Unlock()

	return tx.UnsafeForEach(buckets.Key, func(k, v []byte) (err error) {
		rev := bytesToRev(k)
		rev.main += amount
		revToBytes(k, rev)

		val := mvccpb.KeyValue{}
		if err = val.Unmarshal(v); err != nil {
			return err
		}

		val.ModRevision += amount
		val.Version += amount

		v, err = val.Marshal()
		if err != nil {
			return err
		}

		tx.UnsafeSeqPut(buckets.Key, k, v)
		return nil
	})
}
